# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::DefendantFinder do
  let(:prosecution_case_id) { "5edd67eb-9d8c-44f2-a57e-c8d026defaa4" }
  let(:prosecution_case_reference) { "20GD0217100" }
  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:offence_id) { "3f153786-f3cf-4311-bc0c-2d6f48af68a1" }

  let(:prosecution_cases_json) { file_fixture("prosecution_case_search_result.json").read }
  let(:prosecution_cases_hash) { JSON.parse(prosecution_cases_json) }
  let(:prosecution_case) { prosecution_cases_hash["cases"][0] }

  let(:hearing_json) { file_fixture("hearing_resulted.json").read }

  before do
    ProsecutionCase.create!(id: prosecution_case_id, body: prosecution_case)
    ProsecutionCaseDefendantOffence.create!(
      defendant_id:,
      prosecution_case_id:,
      offence_id:,
    )
  end

  describe "#call", :stub_case_search_with_urn, :stub_hearing_result do
    subject(:defendant) { described_class.call(defendant_id:) }

    it "queries body from prosecutionCases endpoint" do
      defendant
      expect(a_request(:get, %r{.*/prosecutionCases\?prosecutionCaseReference=#{prosecution_case_reference}})).to have_been_made.once
    end

    it "queries details from hearing results endpoint" do
      defendant
      expect(a_request(:get, %r{.*/hearing/results\?hearingId=.*})).to have_been_made.at_least_once
    end

    context "when defendant does exist" do
      it { is_expected.to be_a(Defendant) }

      it "returns the requested Defendant" do
        expect(defendant.id).to eq(defendant_id)
      end

      it { is_expected.to respond_to(:offences) }

      it "includes the expected offence" do
        expect(defendant.offences.map(&:id)).to include(offence_id)
      end

      context "with offence" do
        it "includes plea detail" do
          expect(defendant.offences.flat_map(&:pleas)).to include({ code: "NOT_GUILTY", pleaded_at: "2020-04-12", originating_hearing_id: "818d572c-a9e8-4bf2-8eb7-6abf98cd7a5f" })
        end

        it "includes mode of trial detail" do
          expect(defendant.offences.flat_map(&:mode_of_trial_reasons)).to include({ description: "Court directs trial by jury", code: "5" })
        end
      end
    end

    context "when defendant does not exist" do
      let(:defendant_id) { "2ecc9feb-9407-482f-b081-123456789012" }

      it { is_expected.to be_nil }
    end
  end
end
