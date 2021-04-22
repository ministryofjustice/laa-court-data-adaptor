# frozen_string_literal: true

RSpec.describe Api::Internal::V2::ProviderSerializer do
  subject(:serializable_hash) { described_class.new(provider).serializable_hash }

  let(:provider) do
    instance_double("Provider",
                    id: "PROVIDER_UUID",
                    name: "Neil Griffiths",
                    role: "Junior counsel")
  end

  context "with data" do
    subject(:data) { serializable_hash[:data] }

    it { is_expected.to include(id: "PROVIDER_UUID") }
    it { is_expected.to include(type: :providers) }
    it { is_expected.to have_key(:attributes) }
  end

  context "with attributes" do
    let(:attribute_hash) { serializable_hash[:data][:attributes] }

    it { expect(attribute_hash[:name]).to eq("Neil Griffiths") }
    it { expect(attribute_hash[:role]).to eq("Junior counsel") }
  end
end
