RSpec.describe HmctsCommonPlatform::LaaReference, type: :model do
  let(:laa_reference) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("laa_reference/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:laa_reference)
    end

    it "has an application reference" do
      expect(laa_reference.application_reference).to eql("A10000099")
    end

    it "has a status code" do
      expect(laa_reference.status_code).to eql("AP")
    end

    it "has a status date" do
      expect(laa_reference.status_date).to eql("2020-11-05")
    end

    it "has a status description" do
      expect(laa_reference.status_description).to eql("FAKE NEWS")
    end

    it "has an effective end date" do
      expect(laa_reference.effective_end_date).to eql("2021-04-11")
    end

    it "has an LAA contract number" do
      expect(laa_reference.laa_contract_number).to eql("27900")
    end
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("laa_reference/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:laa_reference)
    end

    it "has an application reference" do
      expect(laa_reference.application_reference).to eql("A10000099")
    end

    it "has a status code" do
      expect(laa_reference.status_code).to eql("AP")
    end

    it "has a status date" do
      expect(laa_reference.status_date).to eql("2020-11-05")
    end

    it "has a status description" do
      expect(laa_reference.status_description).to eql("FAKE NEWS")
    end

    it "has no effective end date" do
      expect(laa_reference.effective_end_date).to be_nil
    end

    it "has no LAA contract number" do
      expect(laa_reference.laa_contract_number).to be_nil
    end
  end
end
