RSpec.describe ProsecutionConclusionContract, type: :model do
  context "with all fields" do
    let(:prosecution_conclusion) { JSON.parse(file_fixture("prosecution_conclusion/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(prosecution_conclusion).to match_json_schema(:prosecution_conclusion)
    end

    it "is valid" do
      expect(described_class.new.call(prosecution_conclusion)).to be_a_success
    end
  end

  context "with required fields only" do
    let(:prosecution_conclusion) { JSON.parse(file_fixture("prosecution_conclusion/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(prosecution_conclusion).to match_json_schema(:prosecution_conclusion)
    end

    it "is valid" do
      expect(described_class.new.call(prosecution_conclusion)).to be_a_success
    end
  end

  context "with valid application conclusion payload" do
    let(:prosecution_conclusion) { JSON.parse(file_fixture("application_conclusion/valid.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(prosecution_conclusion).to match_json_schema(:prosecution_conclusion)
    end

    it "is valid" do
      expect(described_class.new.call(prosecution_conclusion)).to be_a_success
    end
  end

  context "with invalid application conclusion payload" do
    let(:prosecution_conclusion) { JSON.parse(file_fixture("application_conclusion/invalid.json").read) }

    it "does not match the HMCTS Common Platform schema" do
      expect(prosecution_conclusion).not_to match_json_schema(:prosecution_conclusion)
    end

    it "is invalid" do
      expect(described_class.new.call(prosecution_conclusion)).not_to be_a_success
    end
  end
end
