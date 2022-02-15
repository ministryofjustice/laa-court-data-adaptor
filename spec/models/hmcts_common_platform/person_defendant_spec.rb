RSpec.describe HmctsCommonPlatform::PersonDefendant, type: :model do
  let(:data) { JSON.parse(file_fixture("person_defendant.json").read) }
  let(:person_defendant) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:person_defendant)
  end

  it "generates a JSON representation of the data" do
    expect(person_defendant.to_json["arrest_summons_number"]).to eql("TFL1")
    expect(person_defendant.to_json["person_details"]).to be_present
  end

  it { expect(person_defendant.arrest_summons_number).to eql("TFL1") }
  it { expect(person_defendant.first_name).to eql("Carlee") }
  it { expect(person_defendant.last_name).to eql("WilliamsonConnelly") }
  it { expect(person_defendant.date_of_birth).to eql("1990-01-01") }
  it { expect(person_defendant.nino).to eql("AA123456C") }
  it { expect(person_defendant.documentation_language_needs).to eql("WELSH") }
  it { expect(person_defendant.address_1).to eql("Address Line 1") }
  it { expect(person_defendant.address_2).to eql("Address Line 2") }
  it { expect(person_defendant.address_3).to eql("Address Line 3") }
  it { expect(person_defendant.address_4).to eql("Address Line 4") }
  it { expect(person_defendant.address_5).to eql("Address Line 5") }
  it { expect(person_defendant.postcode).to eql("SW1H 9EA") }
  it { expect(person_defendant.phone_home).to eql("000-000-0000") }
  it { expect(person_defendant.phone_work).to eql("111-111-1111") }
  it { expect(person_defendant.phone_mobile).to eql("222-222-2222") }
  it { expect(person_defendant.email_primary).to eql("primary@example.com") }
  it { expect(person_defendant.email_secondary).to eql("secondary@example.com") }
end
