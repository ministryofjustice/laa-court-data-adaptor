RSpec.describe ProsecutionConclusionContract, type: :model do
  let(:prosecution_conclusion) { JSON.parse(file_fixture("prosecution_conclusion/valid.json").read) }

  context "with all fields" do
    it "matches the HMCTS Common Platform schema" do
      expect(prosecution_conclusion).to match_json_schema(:prosecution_conclusion)
    end

    it "is valid" do
      expect(described_class.new.call(prosecution_conclusion)).to be_a_success
    end
  end
end
