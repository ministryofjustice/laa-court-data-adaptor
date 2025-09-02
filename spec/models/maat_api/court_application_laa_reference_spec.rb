RSpec.describe MaatApi::CourtApplicationLaaReference, type: :model do
  subject(:laa_reference) do
    described_class.new(
      user_name:,
      maat_reference:,
      court_application_summary:,
    )
  end

  let(:data) { JSON.parse(file_fixture("court_application_details/all_fields.json").read) }
  let(:court_application_summary) { HmctsCommonPlatform::CourtApplicationSummary.new(data) }
  let(:maat_reference) { "123" }
  let(:user_name) { "test-user" }

  it "has a maat_reference" do
    expect(laa_reference.maat_reference).to eql("123")
  end

  it "uses the short ID as the case URN" do
    expect(laa_reference.case_urn).to eq "A25ABCDE1234"
  end

  it "has a defendant ASN" do
    expect(laa_reference.defendant_asn).to eql("2391NX0000489661589D")
  end

  it "has a cjs area code" do
    expect(laa_reference.cjs_area_code).to eql("1")
  end

  it "has a cjs location" do
    expect(laa_reference.cjs_location).to eql("B01LY")
  end

  it "has a user name" do
    expect(laa_reference.user_name).to eql("test-user")
  end

  it "has a doc language" do
    expect(laa_reference.doc_language).to eql("EN")
  end

  it "has an isActive flag" do
    expect(laa_reference.is_active?).to be true
  end

  it "has a defendant payload" do
    expected = {
      dateOfBirth: "1999-02-06",
      defendantId: "4b463e6a-105b-433b-a88d-057d6e645bfb",
      forename: "Naida",
      nino: "JG101010A",
      surname: "Daniel",
    }

    expect(laa_reference.defendant).to include(expected)
    expect(laa_reference.defendant[:offences]).to be_present
  end
end
