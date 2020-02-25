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
                    offence_ids: ['55555'])
  end

  subject { described_class.new(defendant).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:first_name]).to eq('John') }
    it { expect(attribute_hash[:last_name]).to eq('Doe') }
    it { expect(attribute_hash[:date_of_birth]).to eq('2012-12-12') }
    it { expect(attribute_hash[:national_insurance_number]).to eq('XW858621B') }
  end
end
