RSpec.describe HmctsCommonPlatform::CourtApplicationType, type: :model do
  let(:court_application_type) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("court_application_type/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_type)
    end

    it "has an id" do
      expect(court_application_type.id).to eql("74b72f6f-414a-3464-a4a2-d91397b4c439")
    end

    it "has a description" do
      expect(court_application_type.description).to eql("Application for transfer of legal aid")
    end

    it "has a code" do
      expect(court_application_type.code).to eql("LA12505")
    end

    it "has a category code" do
      expect(court_application_type.category_code).to eql("CO")
    end

    it "has a legislation" do
      expect(court_application_type.legislation).to eql("Pursuant to Regulation 14 of the Criminal Legal Aid")
    end

    it "has an applicant_appellant_flag" do
      expect(court_application_type.applicant_appellant_flag).to be false
    end
  end

  context "with only required fields" do
    let(:data) { JSON.parse(file_fixture("court_application_type/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_type)
    end

    it "has an id" do
      expect(court_application_type.id).to eql("74b72f6f-414a-3464-a4a2-d91397b4c439")
    end

    it "has a description" do
      expect(court_application_type.description).to eql("Application for transfer of legal aid")
    end

    it "has no code" do
      expect(court_application_type.code).to be_nil
    end

    it "has a category code" do
      expect(court_application_type.category_code).to eql("CO")
    end

    it "has no legislation" do
      expect(court_application_type.legislation).to be_nil
    end

    it "has an applicant_appellant_flag" do
      expect(court_application_type.applicant_appellant_flag).to be false
    end
  end
end
