# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProsecutionCaseSerializer do
  let(:prosecution_case) do
    instance_double('ProsecutionCase',
                    id: 'UUID',
                    defendant_first_name: 'John',
                    defendant_last_name: 'Doe',
                    prosecution_case_reference: 'AAA',
                    date_of_birth: '2012-12-12',
                    national_insurance_number: 'XW858621B')
  end

  subject { described_class.new(prosecution_case).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:first_name]).to eq('John') }
    it { expect(attribute_hash[:last_name]).to eq('Doe') }
    it { expect(attribute_hash[:prosecution_case_reference]).to eq('AAA') }
    it { expect(attribute_hash[:date_of_birth]).to eq('2012-12-12') }
    it { expect(attribute_hash[:national_insurance_number]).to eq('XW858621B') }
  end
end
