# frozen_string_literal: true

RSpec.describe ProviderSerializer do
  let(:provider) do
    instance_double('Provider',
                    id: 'PROVIDER_UUID',
                    name: 'Neil Griffiths',
                    role: 'Junior counsel')
  end

  subject { described_class.new(provider).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:name]).to eq('Neil Griffiths') }
    it { expect(attribute_hash[:role]).to eq('Junior counsel') }
  end
end
