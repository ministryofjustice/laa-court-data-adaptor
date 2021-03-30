RSpec.describe HmctsCommonPlatform::PersonDefendant, type: :model do
  let(:data) { JSON.parse(file_fixture("person_defendant.json").read).deep_symbolize_keys }
  let(:person_defendant) { described_class.new(data) }

  it "has an ASN" do
    expect(person_defendant.arrest_summons_number).to eql("TFL1")
  end

  it "has a first name" do
    expect(person_defendant.first_name).to eql("Carlee")
  end

  it "has a last name" do
    expect(person_defendant.last_name).to eql("WilliamsonConnelly")
  end

  it "has a date of birth" do
    expect(person_defendant.date_of_birth).to eql("1990-01-01")
  end

  it "has a NINO" do
    expect(person_defendant.nino).to eql("123456789A")
  end

  it "has documentation language needs" do
    expect(person_defendant.documentation_language_needs).to eql("WELSH")
  end

  it "has address 1" do
    expect(person_defendant.address_1).to eql("Address Line 1")
  end

  it "has address 2" do
    expect(person_defendant.address_2).to eql("Address Line 2")
  end

  it "has address 3" do
    expect(person_defendant.address_3).to eql("Address Line 3")
  end

  it "has address 4" do
    expect(person_defendant.address_4).to eql("Address Line 4")
  end

  it "has address 5" do
    expect(person_defendant.address_5).to eql("Address Line 5")
  end

  it "has a postcode" do
    expect(person_defendant.postcode).to eql("SW1 W11")
  end

  it "has a home phone" do
    expect(person_defendant.phone_home).to eql("000-000-0000")
  end

  it "has a work phone" do
    expect(person_defendant.phone_work).to eql("111-111-1111")
  end

  it "has a mobile phone" do
    expect(person_defendant.phone_mobile).to eql("222-222-2222")
  end

  it "has a primary email" do
    expect(person_defendant.email_primary).to eql("primary@example.com")
  end

  it "has a secondary email" do
    expect(person_defendant.email_secondary).to eql("secondary@example.com")
  end
end
