RSpec.describe HmctsCommonPlatform::DefendantSummary, type: :model do
  let(:data_application_summaries) { JSON.parse(file_fixture("application_summary/all_fields.json").read) }
  let(:defendant_summary) { described_class.new(data, [data_application_summaries]) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("defendant_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant_summary)
    end

    it { expect(defendant_summary.defendant_id).to eql("a86c42dc-6566-4076-9655-b3a53cd58566") }
    it { expect(defendant_summary.first_name).to eql("Bob") }
    it { expect(defendant_summary.middle_name).to eql("Steven") }
    it { expect(defendant_summary.last_name).to eql("Smith") }
    it { expect(defendant_summary.arrest_summons_number).to eql("2100000000000267128K") }
    it { expect(defendant_summary.date_of_birth).to eql("1986-11-10") }
    it { expect(defendant_summary.national_insurance_number).to eql("AA123456C") }
    it { expect(defendant_summary.offence_summaries).to all(be_an(HmctsCommonPlatform::OffenceSummary)) }
    it { expect(defendant_summary.representation_order).to be_an(HmctsCommonPlatform::RepresentationOrder) }
    it { expect(defendant_summary.application_summaries).to all(be_a(HmctsCommonPlatform::ApplicationSummary)) }
  end

  context "with only required fields" do
    let(:data) { JSON.parse(file_fixture("defendant_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant_summary)
    end

    it { expect(defendant_summary.defendant_id).to eql("a86c42dc-6566-4076-9655-b3a53cd58566") }
    it { expect(defendant_summary.name).to eql("Bob Smith") }
    it { expect(defendant_summary.first_name).to be_nil }
    it { expect(defendant_summary.last_name).to be_nil }
    it { expect(defendant_summary.arrest_summons_number).to be_nil }
    it { expect(defendant_summary.date_of_birth).to be_nil }
    it { expect(defendant_summary.national_insurance_number).to be_nil }
    it { expect(defendant_summary.offence_summaries).to all(be_an(HmctsCommonPlatform::OffenceSummary)) }
  end

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("defendant_summary/all_fields.json").read) }

    it "generates a JSON representation of the data" do
      json = defendant_summary.to_json

      expect(json["id"]).to eql("a86c42dc-6566-4076-9655-b3a53cd58566")
      expect(json["first_name"]).to eql("Bob")
      expect(json["middle_name"]).to eql("Steven")
      expect(json["last_name"]).to eql("Smith")
      expect(json["arrest_summons_number"]).to eql("2100000000000267128K")
      expect(json["date_of_birth"]).to eql("1986-11-10")
      expect(json["national_insurance_number"]).to eql("AA123456C")
      expect(json["proceedings_concluded"]).to be false
      expect(json["representation_order"]).to be_present
      expect(json["offence_summaries"].count).to be(2)
      expect(json["application_summaries"].count).to be(1)
    end
  end

  describe "#match_application_summaries" do
    let(:matching_court_application) do
      {
        "applicationId" => "f38d0030-0b4a-4fa5-9484-bb37b1e6ab39",
        "subjectSummary" => {
          "masterDefendantId" => "DEF123",
        },
      }
    end

    let(:not_matching_court_application) do
      {
        "applicationId" => "f38d0030-0b4a-4fa5-9484-bb37b1e6ac56",
        "subjectSummary" => {
          "masterDefendantId" => "DEF145",
        },
      }
    end

    let(:defendant_summary) do
      described_class.new(
        { masterDefendantId: "DEF123" },
        [matching_court_application, not_matching_court_application],
      )
    end

    it "includes only summaries where masterDefendantId matches defendantId" do
      summaries = defendant_summary.application_summaries

      expect(summaries).not_to be_empty
      expect(summaries).to all(be_a(HmctsCommonPlatform::ApplicationSummary))

      application_ids = summaries.map { |summary| summary.data["applicationId"] }

      expect(application_ids).to contain_exactly("f38d0030-0b4a-4fa5-9484-bb37b1e6ab39")
      expect(application_ids).not_to include("f38d0030-0b4a-4fa5-9484-bb37b1e6ac56")
    end
  end
end
