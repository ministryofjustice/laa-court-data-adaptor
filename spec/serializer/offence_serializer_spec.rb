# frozen_string_literal: true

RSpec.describe OffenceSerializer do
  let(:offence) do
    instance_double('Offence',
                    id: 'UUID',
                    code: 'AA06001',
                    order_index: '0',
                    title: 'Fail to wear protective clothing',
                    mode_of_trial: 'Indictable-Only Offence',
                    plea: 'GUILTY',
                    plea_date: '2020-01-01')
  end

  subject { described_class.new(offence).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:code]).to eq('AA06001') }
    it { expect(attribute_hash[:order_index]).to eq('0') }
    it { expect(attribute_hash[:title]).to eq('Fail to wear protective clothing') }
    it { expect(attribute_hash[:mode_of_trial]).to eq('Indictable-Only Offence') }
    it { expect(attribute_hash[:plea]).to eq('GUILTY') }
    it { expect(attribute_hash[:plea_date]).to eq('2020-01-01') }
  end
end
