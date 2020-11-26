# frozen_string_literal: true

RSpec.describe Provider, type: :model do
  let(:provider_hash) do
    JSON.parse(file_fixture("provider.json").read)
  end

  subject(:provider) { described_class.new(body: provider_hash) }

  it { expect(provider.name).to eq("Neil Griffiths") }
  it { expect(provider.role).to eq("Junior counsel") }
  it { expect(provider.id).to eq("a1e3c7a6-c6da-4191-969b-f370fcce46a8") }
end
