# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DefendantSerializer do
  let(:defendant) do
    instance_double('Defendant',
                    id: 'UUID',
                    first_name: 'John',
                    last_name: 'Doe',
                    date_of_birth: '2012-12-12',
                    national_insurance_number: 'XW858621B',
                    gender: 'male',
                    address_1: '1 Main Street',
                    address_2: 'My Town',
                    address_3: 'My City',
                    address_4: 'My County',
                    address_5: 'United Kingdom',
                    postcode: 'AA1 1AA',
                    offence_ids: ['55555'])
  end

  subject { described_class.new(defendant).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:first_name]).to eq('John') }
    it { expect(attribute_hash[:last_name]).to eq('Doe') }
    it { expect(attribute_hash[:date_of_birth]).to eq('2012-12-12') }
    it { expect(attribute_hash[:national_insurance_number]).to eq('XW858621B') }
    it { expect(attribute_hash[:gender]).to eq('male') }
    it { expect(attribute_hash[:address_1]).to eq('1 Main Street') }
    it { expect(attribute_hash[:address_2]).to eq('My Town') }
    it { expect(attribute_hash[:address_3]).to eq('My City') }
    it { expect(attribute_hash[:address_4]).to eq('My County') }
    it { expect(attribute_hash[:address_5]).to eq('United Kingdom') }
    it { expect(attribute_hash[:postcode]).to eq('AA1 1AA') }
  end
end
