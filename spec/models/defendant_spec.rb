# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Defendant, type: :model do
  let(:defendant_hash) do
    {
      'name' => {
        'firstName' => 'Alfredine',
        'lastName' => 'Parker'
      },
      'dateOfBirth' => '1971-05-12',
      'nationalInsuranceNumber' => 'BN102966C'
    }
  end

  subject(:defendant) { described_class.new(body: defendant_hash) }

  before do
    defendant.gender = 'female'
    defendant.address_1 = '102 Petty France'
    defendant.address_2 = 'London'
    defendant.postcode = 'SW1H 9AJ'
  end

  it { expect(defendant.first_name).to eq('Alfredine') }
  it { expect(defendant.last_name).to eq('Parker') }
  it { expect(defendant.date_of_birth).to eq('1971-05-12') }
  it { expect(defendant.national_insurance_number).to eq('BN102966C') }
  it { expect(defendant.gender).to eq('female') }
  it { expect(defendant.address_1).to eq('102 Petty France') }
  it { expect(defendant.address_2).to eq('London') }
  it { expect(defendant.postcode).to eq('SW1H 9AJ') }
end
