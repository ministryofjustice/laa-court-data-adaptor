RSpec.describe HmctsCommonPlatform::DelegatedPowers, type: :model do
  let(:data) { JSON.parse(file_fixture("delegated_powers.json").read) }
  let(:delegated_powers) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:delegated_powers)
  end

  it "has a user id" do
    expect(delegated_powers.user_id).to eql("3462c0f7-278d-4de2-9052-86ed87598961")
  end

  it "has a first name" do
    expect(delegated_powers.first_name).to eql("Ada")
  end

  it "has last name" do
    expect(delegated_powers.last_name).to eql("Lovelace")
  end
end
