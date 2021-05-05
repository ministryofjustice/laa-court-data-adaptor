RSpec.describe HmctsCommonPlatform::Defendant, type: :model do
  let(:defendant) { described_class.new(data) }

  context "when the defendant has all fields" do
    let(:data) { JSON.parse(file_fixture("defendant/all_fields.json").read) }

    it "has a proceedings concluded" do
      expect(defendant.proceedings_concluded).to be(false)
    end

    it "has an ASN" do
      expect(defendant.arrest_summons_number).to eql("TFL1")
    end

    it "has a first name" do
      expect(defendant.first_name).to eql("John")
    end

    it "has a last name" do
      expect(defendant.last_name).to eql("Yundt")
    end

    it "has a date of birth" do
      expect(defendant.date_of_birth).to eql("1990-01-01")
    end

    it "has a NINO" do
      expect(defendant.nino).to eql("123456789A")
    end

    it "has documentation language needs" do
      expect(defendant.documentation_language_needs).to eql("ENGLISH")
    end

    it "has address 1" do
      expect(defendant.address_1).to eql("Address Line 1")
    end

    it "has address 2" do
      expect(defendant.address_2).to eql("Address Line 2")
    end

    it "has address 3" do
      expect(defendant.address_3).to eql("Address Line 3")
    end

    it "has address 4" do
      expect(defendant.address_4).to eql("Address Line 4")
    end

    it "has address 5" do
      expect(defendant.address_5).to eql("Address Line 5")
    end

    it "has a postcode" do
      expect(defendant.postcode).to eql("SW1 W12")
    end

    it "has a home phone" do
      expect(defendant.phone_home).to eql("000-000-0000")
    end

    it "has a work phone" do
      expect(defendant.phone_work).to eql("111-111-1111")
    end

    it "has a mobile phone" do
      expect(defendant.phone_mobile).to eql("222-222-2222")
    end

    it "has a primary email" do
      expect(defendant.email_primary).to eql("primary@example.com")
    end

    it "has a secondary email" do
      expect(defendant.email_secondary).to eql("secondary@example.com")
    end

    it "has offences" do
      expect(defendant.offences).to all(be_a(HmctsCommonPlatform::Offence))
      expect(defendant.offences).to be_a(Array)
    end
  end

  context "when the defendant has only required fields" do
    let(:data) { JSON.parse(file_fixture("defendant/required_fields.json").read).deep_symbolize_keys }

    it "has no proceedings concluded" do
      expect(defendant.proceedings_concluded).to be_nil
    end

    it "has no ASN" do
      expect(defendant.arrest_summons_number).to be_nil
    end

    it "has no first name" do
      expect(defendant.first_name).to be_nil
    end

    it "has no last name" do
      expect(defendant.last_name).to be_nil
    end

    it "has no date of birth" do
      expect(defendant.date_of_birth).to be_nil
    end

    it "has no NINO" do
      expect(defendant.nino).to be_nil
    end

    it "has documentation no language needs" do
      expect(defendant.documentation_language_needs).to be_nil
    end

    it "has no address 1" do
      expect(defendant.address_1).to be_nil
    end

    it "has no address 2" do
      expect(defendant.address_2).to be_nil
    end

    it "has no address 3" do
      expect(defendant.address_3).to be_nil
    end

    it "has no address 4" do
      expect(defendant.address_4).to be_nil
    end

    it "has no address 5" do
      expect(defendant.address_5).to be_nil
    end

    it "has no postcode" do
      expect(defendant.postcode).to be_nil
    end

    it "has no home phone" do
      expect(defendant.phone_home).to be_nil
    end

    it "has no work phone" do
      expect(defendant.phone_work).to be_nil
    end

    it "has no mobile phone" do
      expect(defendant.phone_mobile).to be_nil
    end

    it "has no primary email" do
      expect(defendant.email_primary).to be_nil
    end

    it "has no secondary email" do
      expect(defendant.email_secondary).to be_nil
    end

    describe "offences" do
      it "are HmctsCommonPlatform::Offence objects" do
        expect(defendant.offences).to all(be_a(HmctsCommonPlatform::Offence))
        expect(defendant.offences).to be_a(Array)
      end
    end
  end
end
