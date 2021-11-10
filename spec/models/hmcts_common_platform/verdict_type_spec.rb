RSpec.describe HmctsCommonPlatform::VerdictType, type: :model do
  let(:verdict_type) { described_class.new(data) }

  context "when verdict has all fields" do
    let(:data) { JSON.parse(file_fixture("verdict_type/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:verdict_type)
    end

    it "has an ID" do
      expect(verdict_type.id).to eql("f8df61d4-6e89-4b3f-85b4-5bfbc137a0b7")
    end

    it "has a category" do
      expect(verdict_type.category).to eql("A")
    end

    it "has a category type" do
      expect(verdict_type.category_type).to eql("Type A")
    end

    it "has a verdict code" do
      expect(verdict_type.verdict_code).to eql("367A")
    end

    it "has a CJS verdict code" do
      expect(verdict_type.cjs_verdict_code).to eql("1093")
    end

    it "has a sequence" do
      expect(verdict_type.sequence).to be(1)
    end

    it "has a description" do
      expect(verdict_type.description).to eql("a verdict type description")
    end
  end
end
