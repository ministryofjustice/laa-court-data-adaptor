RSpec.describe HmctsCommonPlatform::DefendantCase, type: :model do
  let(:defendant_case) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("defendant_case/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant_case)
    end

    it "has a defendant ID" do
      expect(defendant_case.defendant_id).to eql("eafdd97b-7e81-41cc-b92e-fb86fbcb2ebf")
    end
  end

  context "with required fields" do
    let(:data) { JSON.parse(file_fixture("defendant_case/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant_case)
    end

    it "has a defendant ID" do
      expect(defendant_case.defendant_id).to eql("eafdd97b-7e81-41cc-b92e-fb86fbcb2ebf")
    end
  end
end
