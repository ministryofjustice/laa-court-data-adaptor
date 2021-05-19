RSpec.describe HmctsCommonPlatform::CourtApplication, type: :model do
  let(:data) { JSON.parse(file_fixture("court_application.json").read) }
  let(:court_application) { described_class.new(data) }

  it "has an id" do
    expect(court_application.id).to eql("c5266a93-389c-4331-a56a-dd000b361cef")
  end

  it "has a type id" do
    expect(court_application.type_id).to eql("74b72f6f-414a-3464-a4a2-d91397b4c439")
  end

  it "has a type name" do
    expect(court_application.type_description).to eql("Application for transfer of legal aid")
  end

  it "has a type code" do
    expect(court_application.type_code).to eql("LA12505")
  end

  it "has a type category code" do
    expect(court_application.type_category_code).to eql("CO")
  end

  it "has a type legislation" do
    expect(court_application.type_legislation).to eql("Pursuant to Regulation 14 of the Criminal Legal Aid")
  end

  it "has an application particulars" do
    expect(court_application.application_particulars).to eql("application particulars")
  end

  it "has a received date" do
    expect(court_application.received_date).to eql("2021-03-09")
  end

  describe "defendant" do
    it "has an ASN" do
      expect(court_application.defendant_arrest_summons_number).to eql("TFL1")
    end

    it "has a first name" do
      expect(court_application.defendant_first_name).to eql("Carlee")
    end

    it "has a last name" do
      expect(court_application.defendant_last_name).to eql("WilliamsonConnelly")
    end

    it "has a date of birth" do
      expect(court_application.defendant_date_of_birth).to eql("1990-01-01")
    end

    it "has a NINO" do
      expect(court_application.defendant_nino).to eql("123456789A")
    end

    it "has documentation language needs" do
      expect(court_application.defendant_documentation_language_needs).to eql("WELSH")
    end

    it "has address 1" do
      expect(court_application.defendant_address_1).to eql("Address Line 1")
    end

    it "has address 2" do
      expect(court_application.defendant_address_2).to eql("Address Line 2")
    end

    it "has address 3" do
      expect(court_application.defendant_address_3).to eql("Address Line 3")
    end

    it "has address 4" do
      expect(court_application.defendant_address_4).to eql("Address Line 4")
    end

    it "has address 5" do
      expect(court_application.defendant_address_5).to eql("Address Line 5")
    end

    it "has a postcode" do
      expect(court_application.defendant_postcode).to eql("SW1 W11")
    end

    it "has a home phone" do
      expect(court_application.defendant_phone_home).to eql("000-000-0000")
    end

    it "has a work phone" do
      expect(court_application.defendant_phone_work).to eql("111-111-1111")
    end

    it "has a mobile phone" do
      expect(court_application.defendant_phone_mobile).to eql("222-222-2222")
    end

    it "has a primary email" do
      expect(court_application.defendant_email_primary).to eql("primary@example.com")
    end

    it "has a secondary email" do
      expect(court_application.defendant_email_secondary).to eql("secondary@example.com")
    end
  end

  describe "respondents" do
    it "are HmctsCommonPlatform::CourtApplicationParty objects" do
      expect(court_application.respondents).to all(be_a(HmctsCommonPlatform::CourtApplicationParty))
    end
  end

  describe "judicial results" do
    it "are HmctsCommonPlatform::JudicialResult objects" do
      expect(court_application.judicial_results).to all(be_a(HmctsCommonPlatform::JudicialResult))
    end
  end
end
