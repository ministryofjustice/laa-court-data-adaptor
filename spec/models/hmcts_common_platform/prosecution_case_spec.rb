RSpec.describe HmctsCommonPlatform::ProsecutionCase, type: :model do
  let(:prosecution_case) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("prosecution_case/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:prosecution_case)
    end

    it "has a URN" do
      expect(prosecution_case.urn).to eql("20GD0217100")
    end

    it "has defendants" do
      expect(prosecution_case.defendants).to all(be_a(HmctsCommonPlatform::Defendant))
    end
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("prosecution_case/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:prosecution_case)
    end

    it "has a URN" do
      expect(prosecution_case.urn).to eql("20GD0217100")
    end

    it "has defendants" do
      expect(prosecution_case.defendants).to all(be_a(HmctsCommonPlatform::Defendant))
    end
  end
end
