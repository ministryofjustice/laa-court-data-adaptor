# frozen_string_literal: true

RSpec.describe ProsecutionCase, type: :model do
  let(:hearing_one) do
    Hearing.create(
      id: hearing_ids[0],
      body: {
        "hearing" => {
          "id" => hearing_ids[0],
          "prosecutionCases" => [{
            "id" => "31cbe62d-b1ec-4e82-89f7-99dced834900",
            "defendants" => [{
              "id" => "c6cf04b5-901d-4a89-a9ab-767eb57306e4",
              "offences": [
                {
                  "id": "offence-one-id",
                },
              ],
            }],
          }],
        },
        "sharedTime" => "2020-12-12",
      },
    )
  end

  let(:hearing_two) do
    Hearing.create(
      id: hearing_ids[1],
      body: {

        "hearing" => {
          "id" => hearing_ids[1],
          "prosecutionCases" => [{
            "id" => "31cbe62d-b1ec-4e82-89f7-99dced834900",
            "defendants" => [{
              "id" => "c6cf04b5-901d-4a89-a9ab-767eb57306e4",
              "offences": [
                {
                  "id": "offence-two-id",
                },
              ],
            },
                             {
                               "id" => "b70a36e5-13d3-4bb3-bb24-94db79b7708b",
                               "offences": [
                                 {
                                   "id": "offence-three-id",
                                 },
                               ],
                             }],
          }],
        },
        "sharedTime" => "2020-10-20",
      },
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "Common Platform search" do
    let(:prosecution_case_result) do
      VCR.use_cassette("search_prosecution_case/by_prosecution_case_reference_success") do
        CommonPlatformApi::ProsecutionCaseSearcher.call(prosecution_case_reference: "19GD1001816")
      end
    end

    let(:prosecution_case) { described_class.create(id: prosecution_case_id, body: prosecution_case_result.body["cases"][0]) }
    let(:prosecution_case_id) { "31cbe62d-b1ec-4e82-89f7-99dced834900" }

    describe "#prosecution_case_reference" do
      it { expect(prosecution_case.prosecution_case_reference).to eq("19GD1001816") }
    end

    describe "#defendants" do
      it { expect(prosecution_case.defendants).to all be_a(Defendant) }

      it "initialises Defendants without details" do
        expect(Defendant).to receive(:new).with(body: an_instance_of(Hash), details: nil, prosecution_case_id: prosecution_case_id).twice.and_call_original
        prosecution_case.defendants
      end
    end

    describe "#hearing_summaries" do
      it { expect(prosecution_case.hearing_summaries).to all be_a(HearingSummary) }
    end

    context "when requesting hearing resulted" do
      let(:hearing_ids) { %w[311bb2df-4df5-4abe-bae3-82f144e1e5c5 e8d88eaa-e73f-4b59-8148-d0cfbbd3520b] }

      before do
        allow(prosecution_case).to receive(:hearing_summary_ids).and_return(hearing_ids)
        allow(CommonPlatformApi::GetHearingResults).to receive(:call).with(hearing_id: hearing_ids[0]).and_return(hearing_one)
        allow(CommonPlatformApi::GetHearingResults).to receive(:call).with(hearing_id: hearing_ids[1]).and_return(hearing_two)
      end

      describe "#hearing_ids" do
        subject { prosecution_case.hearing_ids }

        it { is_expected.to eq(hearing_ids) }
      end

      describe "#hearings" do
        subject(:hearings) { prosecution_case.hearings }

        it { is_expected.to all be_a(Hearing) }

        it "is_expected to have alias #fetch_details" do
          expect(prosecution_case.method(:hearings)).to eq(prosecution_case.method(:fetch_details))
        end

        context "when a hearing has not resulted" do
          let(:hearing_one) { nil }
          let(:hearing_two) { nil }

          it { is_expected.to be_empty }
        end

        context "when hearings are loaded" do
          let(:defendant_one_details) do
            [{
              "id" => "c6cf04b5-901d-4a89-a9ab-767eb57306e4",
              "offences" => [{ "id" => "offence-one-id" }],
            },
             {
               "id" => "c6cf04b5-901d-4a89-a9ab-767eb57306e4",
               "offences" => [{ "id" => "offence-two-id" }],
             }]
          end

          let(:defendant_two_details) do
            [{
              "id" => "b70a36e5-13d3-4bb3-bb24-94db79b7708b",
              "offences" => [{ "id" => "offence-three-id" }],
            }]
          end

          before { prosecution_case.hearings }

          it "initialises Defendants with detail fetched from hearing" do
            expect(Defendant).to receive(:new).with(body: an_instance_of(Hash), details: defendant_one_details, prosecution_case_id: prosecution_case_id).once
            expect(Defendant).to receive(:new).with(body: an_instance_of(Hash), details: defendant_two_details, prosecution_case_id: prosecution_case_id).once
            prosecution_case.defendants
          end

          context "with no prosecution_case reference" do
            let(:hearing_one) { Hearing.create(id: hearing_ids[0], body: { "hearing" => { "id" => hearing_ids[0] } }) }
            let(:hearing_two) { Hearing.create(id: hearing_ids[1], body: { "hearing" => { "id" => hearing_ids[1] } }) }

            it "initialises Defendants without details" do
              expect(Defendant).to receive(:new).with(body: an_instance_of(Hash), details: nil, prosecution_case_id: prosecution_case_id).twice
              prosecution_case.defendants
            end
          end
        end
      end
    end
  end
end
