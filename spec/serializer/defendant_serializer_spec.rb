# frozen_string_literal: true

RSpec.describe DefendantSerializer do
  let(:defendant) do
    instance_double('Defendant',
                    id: 'UUID',
                    name: 'John Doe',
                    date_of_birth: '2012-12-12',
                    national_insurance_number: 'XW858621B',
                    arrest_summons_number: 'MG25A11223344',
                    maat_reference: '123123',
                    representation_order_date: '2020-12-12',
                    offence_ids: ['55555'],
                    defence_organisation_id: '88888',
                    prosecution_case_id: '5edd67eb-9d8c-44f2-a57e-c8d026defaa4',
                    post_hearing_custody_status: 'A')
  end

  subject { described_class.new(defendant).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:name]).to eq('John Doe') }
    it { expect(attribute_hash[:date_of_birth]).to eq('2012-12-12') }
    it { expect(attribute_hash[:national_insurance_number]).to eq('XW858621B') }
    it { expect(attribute_hash[:arrest_summons_number]).to eq('MG25A11223344') }
    it { expect(attribute_hash[:maat_reference]).to eq('123123') }
    it { expect(attribute_hash[:representation_order_date]).to eq('2020-12-12') }
    it { expect(attribute_hash[:prosecution_case_id]).to eq('5edd67eb-9d8c-44f2-a57e-c8d026defaa4') }
    it { expect(attribute_hash[:post_hearing_custody_status]).to eq('A') }
  end

  context 'relationships' do
    let(:relationship_hash) { subject[:data][:relationships] }

    it { expect(relationship_hash[:offences][:data]).to eq([{ id: '55555', type: :offences }]) }
    it { expect(relationship_hash[:defence_organisation][:data]).to eq({ id: '88888', type: :defence_organisations }) }
    it { expect(relationship_hash[:prosecution_case][:data]).to eq({ id: '5edd67eb-9d8c-44f2-a57e-c8d026defaa4', type: :prosecution_case }) }
  end
end
