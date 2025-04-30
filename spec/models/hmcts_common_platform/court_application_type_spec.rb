RSpec.describe HmctsCommonPlatform::CourtApplicationType, type: :model do
  let(:court_application_type) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("court_application_type/all_fields.json").read) }

  describe "#to_json" do
    it "generates a JSON representation of the data" do
      expect(court_application_type.to_json["id"]).to eql("74b72f6f-414a-3464-a4a2-d91397b4c439")
      expect(court_application_type.to_json["description"]).to eql("Application for transfer of legal aid")
      expect(court_application_type.to_json["code"]).to eql("LA12505")
      expect(court_application_type.to_json["category_code"]).to eql("CO")
      expect(court_application_type.to_json["legislation"]).to eql("Pursuant to Regulation 14 of the Criminal Legal Aid")
      expect(court_application_type.to_json["applicant_appellant_flag"]).to be false
      expect(court_application_type.to_json["link_type"]).to eql("LINKED")
      expect(court_application_type.to_json["jurisdiction"]).to eql("EITHER")
      expect(court_application_type.to_json["appeal_flag"]).to be false
      expect(court_application_type.to_json["plea_applicable_flag"]).to be false
      expect(court_application_type.to_json["summons_template_type"]).to eql("NOT_APPLICABLE")
      expect(court_application_type.to_json["valid_from"]).to eql("2022-01-01")
      expect(court_application_type.to_json["valid_to"]).to be_nil
      expect(court_application_type.to_json["offence_active_order"]).to eql("NOT_APPLICABLE")
      expect(court_application_type.to_json["commr_of_oath_flag"]).to be false
      expect(court_application_type.to_json["breach_type"]).to eql("NOT_APPLICABLE")
      expect(court_application_type.to_json["court_of_appeal_flag"]).to be false
      expect(court_application_type.to_json["court_extract_avl_flag"]).to be true
      expect(court_application_type.to_json["listing_notif_template"]).to eql("POSTAL_NOTIFICATION")
      expect(court_application_type.to_json["boxwork_notif_template"]).to eql("NOT_APPLICABLE")
      expect(court_application_type.to_json["prosecutor_third_party_flag"]).to be false
      expect(court_application_type.to_json["spi_out_applicable_flag"]).to be true
      expect(court_application_type.to_json["hearing_code"]).to eql("APN")
    end
  end

  context "with all fields" do
    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_type)
    end

    it { expect(court_application_type.id).to eql("74b72f6f-414a-3464-a4a2-d91397b4c439") }
    it { expect(court_application_type.description).to eql("Application for transfer of legal aid") }
    it { expect(court_application_type.code).to eql("LA12505") }
    it { expect(court_application_type.category_code).to eql("CO") }
    it { expect(court_application_type.legislation).to eql("Pursuant to Regulation 14 of the Criminal Legal Aid") }
    it { expect(court_application_type.applicant_appellant_flag).to be false }
    it { expect(court_application_type.link_type).to eql("LINKED") }
    it { expect(court_application_type.jurisdiction).to eql("EITHER") }
    it { expect(court_application_type.appeal_flag).to be false }
    it { expect(court_application_type.plea_applicable_flag).to be false }
    it { expect(court_application_type.summons_template_type).to eql("NOT_APPLICABLE") }
    it { expect(court_application_type.valid_from).to eql("2022-01-01") }
    it { expect(court_application_type.offence_active_order).to eql("NOT_APPLICABLE") }
    it { expect(court_application_type.commr_of_oath_flag).to be false }
    it { expect(court_application_type.breach_type).to eql("NOT_APPLICABLE") }
    it { expect(court_application_type.court_of_appeal_flag).to be false }
    it { expect(court_application_type.court_extract_avl_flag).to be true }
    it { expect(court_application_type.listing_notif_template).to eql("POSTAL_NOTIFICATION") }
    it { expect(court_application_type.boxwork_notif_template).to eql("NOT_APPLICABLE") }
    it { expect(court_application_type.prosecutor_third_party_flag).to be false }
    it { expect(court_application_type.spi_out_applicable_flag).to be true }
    it { expect(court_application_type.hearing_code).to eql("APN") }
  end

  context "with only required fields" do
    let(:data) { JSON.parse(file_fixture("court_application_type/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:court_application_type)
    end

    it { expect(court_application_type.id).to eql("74b72f6f-414a-3464-a4a2-d91397b4c439") }
    it { expect(court_application_type.description).to eql("Application for transfer of legal aid") }
    it { expect(court_application_type.category_code).to eql("CO") }
    it { expect(court_application_type.link_type).to eql("LINKED") }
    it { expect(court_application_type.jurisdiction).to eql("EITHER") }
    it { expect(court_application_type.summons_template_type).to eql("NOT_APPLICABLE") }
    it { expect(court_application_type.breach_type).to eql("NOT_APPLICABLE") }
    it { expect(court_application_type.offence_active_order).to eql("NOT_APPLICABLE") }
    it { expect(court_application_type.appeal_flag).to be false }
    it { expect(court_application_type.applicant_appellant_flag).to be false }
    it { expect(court_application_type.plea_applicable_flag).to be false }
    it { expect(court_application_type.court_of_appeal_flag).to be false }
    it { expect(court_application_type.court_extract_avl_flag).to be true }
    it { expect(court_application_type.commr_of_oath_flag).to be false }
    it { expect(court_application_type.prosecutor_third_party_flag).to be false }
    it { expect(court_application_type.spi_out_applicable_flag).to be true }
  end
end
