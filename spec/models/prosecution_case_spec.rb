# frozen_string_literal: true

RSpec.describe ProsecutionCase, type: :model do
  let(:hearing_result_body) do
    {
      "sharedTime" => "",
      "hearing" => {
        "id" => "0c401e0d-9d88-4cb8-8543-2090782edd32",
        "prosecutionCases" => [
          {
            "id" => "31cbe62d-b1ec-4e82-89f7-99dced834900",
            "defendants" => [
              {
                "id" => "cfc4281f-cdea-494d-8179-3173d30736fd",
                "offences" => [
                  {
                    "id" => "offence-one-id",
                  },
                ],
              },
            ],
          },
        ],
      },
    }
  end

  let(:prosecution_case_reference) { "61GD7528225" }
  let(:prosecution_cases_json) { file_fixture("prosecution_cases_v2.json").read }
  let(:prosecution_cases) { JSON.parse(prosecution_cases_json) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "Common Platform search", :stub_case_search_with_urn do
    let(:prosecution_case) do
      described_class.new(id: prosecution_case_id, body: prosecution_cases["cases"][0])
    end

    let(:prosecution_case_id) { "6fc1f2cb-4a93-4116-84db-f87cc86ec3b8" }

    describe "#prosecution_case_reference" do
      it { expect(prosecution_case.prosecution_case_reference).to eq("61GD7528225") }
    end

    describe "#hearing_summaries" do
      it { expect(prosecution_case.hearing_summaries).to all be_an(HmctsCommonPlatform::HearingSummary) }
    end

    context "when GetHearingResults returns a hearing" do
      before do
        allow(CommonPlatform::Api::GetHearingResults).to receive(:call)
          .with(hearing_id: "0c401e0d-9d88-4cb8-8543-2090782edd32", sitting_day: "2025-02-18T09:01:01.001Z")
          .and_return(hearing_result_body)
      end

      describe "#defendants" do
        subject(:defendants) { prosecution_case.defendants }

        it { is_expected.to all be_a(Defendant) }

        it "returns Defendants with detail fetched from hearings" do
          expect(prosecution_case.defendants.count).to eq(1)

          expect(prosecution_case.defendants.first.id).to eq("cfc4281f-cdea-494d-8179-3173d30736fd")

          expect(prosecution_case.defendants.first.offences.count).to eq(2)

          # Offence codes TW01040, TW01046 comes from the prosecution_cases_v2.json fixture
          expect(prosecution_case.defendants.first.offences.map(&:code)).to eq(%w[TW01040 TW01046])
        end
      end

      describe "defendant_ids" do
        subject(:defendant_ids) { prosecution_case.defendant_ids }

        it { is_expected.to eq(%w[cfc4281f-cdea-494d-8179-3173d30736fd]) }
      end

      describe "#hearings" do
        subject(:hearings) { prosecution_case.hearings }

        it { is_expected.to all be_a(Hearing) }

        it { expect(hearings.first.id).to eq(hearing_result_body["hearing"]["id"]) }

        it "is_expected to have alias #fetch_details" do
          expect(prosecution_case.method(:hearings)).to eq(prosecution_case.method(:fetch_details))
        end

        context "with no prosecution_case reference" do
          let(:hearing_result_body) do
            HearingResult.new({ "sharedTime" => "", "hearing" => { "id" => "311bb2df-4df5-4abe-bae3-82f144e1e5c5" } })
          end

          it "details are not fetched" do
            expect(prosecution_case.defendants.first.details).to be_nil
          end
        end

        context "when a hearing is not found" do
          let(:hearing_result_body) { {} }

          it { is_expected.to be_empty }
        end
      end
    end
  end
end
