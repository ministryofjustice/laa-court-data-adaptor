# frozen_string_literal: true

RSpec.describe DefendantSerializer do
  let(:defendant) do
    instance_double('Defendant',
                    id: 'UUID',
                    first_name: 'John',
                    last_name: 'Doe',
                    date_of_birth: '2012-12-12',
                    national_insurance_number: 'XW858621B',
                    arrest_summons_number: 'MG25A11223344',
                    linked?: false,
                    offence_ids: ['55555'])
  end

  subject { described_class.new(defendant).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:first_name]).to eq('John') }
    it { expect(attribute_hash[:last_name]).to eq('Doe') }
    it { expect(attribute_hash[:date_of_birth]).to eq('2012-12-12') }
    it { expect(attribute_hash[:national_insurance_number]).to eq('XW858621B') }
    it { expect(attribute_hash[:arrest_summons_number]).to eq('MG25A11223344') }
    it { expect(attribute_hash[:is_linked]).to eq(false) }
  end

  context 'relationships' do
    let(:relationship_hash) { subject[:data][:relationships] }

    it { expect(relationship_hash[:offences][:data]).to eq([id: '55555', type: :offences]) }
  end
end
