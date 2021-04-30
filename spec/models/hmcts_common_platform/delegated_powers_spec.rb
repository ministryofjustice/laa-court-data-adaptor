RSpec.describe HmctsCommonPlatform::DelegatedPowers, type: :model do
  let(:data) { JSON.parse(file_fixture("delegated_powers.json").read) }
  let(:delegated_powers) { described_class.new(data) }

  it "has a user id" do
    expect(delegated_powers.user_id).to eql("sd22b110-0pbc-3136-a076-e4bb40d0a986")
  end

  it "has a first name" do
    expect(delegated_powers.first_name).to eql("Ada")
  end

  it "has last name" do
    expect(delegated_powers.last_name).to eql("Lovelace")
  end
end
