RSpec.describe HmctsCommonPlatform::ContactDetails, type: :model do
  let(:contact_details) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("contact_details.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:contact_details)
  end

  it "generates a JSON representation of the data" do
    expect(contact_details.to_json["home"]).to eql("000-000-0000")
    expect(contact_details.to_json["work"]).to eql("111-111-1111")
    expect(contact_details.to_json["mobile"]).to eql("222-222-2222")
    expect(contact_details.to_json["email_primary"]).to eql("primary@example.com")
    expect(contact_details.to_json["email_secondary"]).to eql("secondary@example.com")
    expect(contact_details.to_json["fax"]).to eql("333-333-3333")
  end

  it { expect(contact_details.phone_home).to eql("000-000-0000") }
  it { expect(contact_details.phone_work).to eql("111-111-1111") }
  it { expect(contact_details.phone_mobile).to eql("222-222-2222") }
  it { expect(contact_details.email_primary).to eql("primary@example.com") }
  it { expect(contact_details.email_secondary).to eql("secondary@example.com") }
  it { expect(contact_details.fax).to eql("333-333-3333") }
end
