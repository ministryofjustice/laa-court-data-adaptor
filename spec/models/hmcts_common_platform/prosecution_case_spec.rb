RSpec.describe HmctsCommonPlatform::ProsecutionCase, type: :model do
  let(:defendant) { JSON.parse(file_fixture("defendant.json").read).deep_symbolize_keys }
  let(:prosecution_case) { described_class.new(defendant) }

  describe "defendant" do
    it "has a proceedings concluded" do
      expect(prosecution_case.proceedings_concluded).to be(false)
    end

    it "has an ASN" do
      expect(prosecution_case.defendant_arrest_summons_number).to eql("TFL1")
    end

    it "has a first name" do
      expect(prosecution_case.defendant_first_name).to eql("John")
    end

    it "has a last name" do
      expect(prosecution_case.defendant_last_name).to eql("Yundt")
    end

    it "has a date of birth" do
      expect(prosecution_case.defendant_date_of_birth).to eql("1990-01-01")
    end

    it "has a NINO" do
      expect(prosecution_case.defendant_nino).to eql("123456789A")
    end

    it "has documentation language needs" do
      expect(prosecution_case.defendant_documentation_language_needs).to eql("ENGLISH")
    end

    it "has address 1" do
      expect(prosecution_case.defendant_address_1).to eql("Address Line 1")
    end

    it "has address 2" do
      expect(prosecution_case.defendant_address_2).to eql("Address Line 2")
    end

    it "has address 3" do
      expect(prosecution_case.defendant_address_3).to eql("Address Line 3")
    end

    it "has address 4" do
      expect(prosecution_case.defendant_address_4).to eql("Address Line 4")
    end

    it "has address 5" do
      expect(prosecution_case.defendant_address_5).to eql("Address Line 5")
    end

    it "has a postcode" do
      expect(prosecution_case.defendant_postcode).to eql("SW1 W12")
    end

    it "has a home phone" do
      expect(prosecution_case.defendant_phone_home).to eql("000-000-0000")
    end

    it "has a work phone" do
      expect(prosecution_case.defendant_phone_work).to eql("111-111-1111")
    end

    it "has a mobile phone" do
      expect(prosecution_case.defendant_phone_mobile).to eql("222-222-2222")
    end

    it "has a primary email" do
      expect(prosecution_case.defendant_email_primary).to eql("primary@example.com")
    end

    it "has a secondary email" do
      expect(prosecution_case.defendant_email_secondary).to eql("secondary@example.com")
    end
  end

  describe "offences" do
    it "are HmctsCommonPlatform::Offence objects" do
      expect(prosecution_case.offences).to all(be_a(HmctsCommonPlatform::Offence))
      expect(prosecution_case.offences).to be_a(Array)
    end
  end
end
