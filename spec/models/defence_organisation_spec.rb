# frozen_string_literal: true

RSpec.describe DefenceOrganisation, type: :model do
  let(:defence_organisation_hash) do
    JSON.parse(file_fixture("defence_organisation.json").read)
  end

  subject(:defendant) { described_class.new(body: defence_organisation_hash) }

  it { expect(defendant.id).to eq("CONTRACT REFERENCE") }
  it { expect(defendant.name).to eq("SOME ORGANISATION") }
  it { expect(defendant.address1).to eq("102") }
  it { expect(defendant.address2).to eq("Petty France") }
  it { expect(defendant.address3).to eq("Floor 5") }
  it { expect(defendant.address4).to eq("St James") }
  it { expect(defendant.address5).to eq("Westminster") }
  it { expect(defendant.postcode).to eq("EC4A 2AH") }
end
