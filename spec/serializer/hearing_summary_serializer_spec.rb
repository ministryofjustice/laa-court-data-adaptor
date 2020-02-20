# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingSummarySerializer do
  let(:hearing_summary) do
    instance_double('HearingSummary',
                    id: 'UUID',
                    jurisdiction_type: 'Magistrate',
                    court_centre_id: '1',
                    court_centre_name: 'Westminster',
                    court_centre_welsh_name: 'Westminster',
                    court_centre_room_id: '1',
                    court_centre_room_name: 'Court 1',
                    court_centre_welsh_room_name: 'Court 1',
                    court_centre_address_1: 'Westminster Magistrates Court',
                    court_centre_address_2: '181 Marylebone Road',
                    court_centre_address_3: 'Westminster',
                    court_centre_address_4: 'London',
                    court_centre_address_5: 'United Kingdom',
                    court_centre_postcode: 'NW1 5BR',
                    hearing_type_id: '1',
                    hearing_type_description: 'Committal for Sentencing',
                    hearing_type_code: 'AA1',
                    defendants: ['UUID'],
                    hearing_date: '2020-02-01')
  end

  subject { described_class.new(hearing_summary).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:jurisdiction_type]).to eq('Magistrate') }
    it { expect(attribute_hash[:court_centre_id]).to eq('1') }
    it { expect(attribute_hash[:court_centre_name]).to eq('Westminster') }
    it { expect(attribute_hash[:court_centre_welsh_name]).to eq('Westminster') }
    it { expect(attribute_hash[:court_centre_room_id]).to eq('1') }
    it { expect(attribute_hash[:court_centre_room_name]).to eq('Court 1') }
    it { expect(attribute_hash[:court_centre_welsh_room_name]).to eq('Court 1') }
    it { expect(attribute_hash[:court_centre_address_1]).to eq('Westminster Magistrates Court') }
    it { expect(attribute_hash[:court_centre_address_2]).to eq('181 Marylebone Road') }
    it { expect(attribute_hash[:court_centre_address_3]).to eq('Westminster') }
    it { expect(attribute_hash[:court_centre_address_4]).to eq('London') }
    it { expect(attribute_hash[:court_centre_address_5]).to eq('United Kingdom') }
    it { expect(attribute_hash[:court_centre_postcode]).to eq('NW1 5BR') }
    it { expect(attribute_hash[:hearing_type_id]).to eq('1') }
    it { expect(attribute_hash[:hearing_type_description]).to eq('Committal for Sentencing') }
    it { expect(attribute_hash[:hearing_type_code]).to eq('AA1') }
    it { expect(attribute_hash[:defendants]).to eq(['UUID']) }
    it { expect(attribute_hash[:hearing_date]).to eq('2020-02-01') }
  end
end
