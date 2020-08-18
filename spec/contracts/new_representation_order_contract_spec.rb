# frozen_string_literal: true

RSpec.describe NewRepresentationOrderContract do
  subject { described_class.new.call(hash_for_validation) }

  let(:hash_for_validation) do
    {
      maat_reference: maat_reference,
      defence_organisation: defence_organisation,
      offences: offences_array,
      defendant_id: '17154890-67d2-48af-af1e-7ce7eef2b8c6'
    }
  end
  let(:maat_reference) { 123_456_789 }
  let(:defence_organisation) do
    {
      laa_contract_number: 'CONTRACT REFERENCE',
      sra_number: 'SRA NUMBER',
      bar_council_membership_number: 'BAR COUNCIL NUMBER',
      incorporation_number: 'AAA',
      registered_charity_number: 'BBB',
      organisation: {
        name: 'SOME ORGANISATION',
        address: {
          address1: 'String',
          address2: 'String',
          address3: 'String',
          address4: 'String',
          address5: 'String',
          postcode: 'EC4A 2AH'
        },
        contact: {
          home: '+99999',
          work: 'String',
          mobile: '+99999',
          primary_email: 'a@example.com',
          secondary_email: 'a@example.com',
          fax: 'String'
        }
      }
    }
  end

  let(:offences_array) do
    [
      {
        offence_id: '23d7f10a-067a-476e-bba6-bb855674e23b',
        status_code: 'GR',
        status_date: Date.new(2020, 2, 12),
        effective_start_date: Date.new(2020, 2, 20),
        effective_end_date: Date.new(2020, 2, 25)
      }, {
        offence_id: '4b43a507-4450-4d08-9362-70ae7e3e8b6e',
        status_code: 'FB',
        status_date: Date.new(2020, 2, 13),
        effective_start_date: Date.new(2020, 2, 20),
        effective_end_date: Date.new(2020, 2, 25)
      }
    ]
  end

  it { is_expected.to be_a_success }

  context 'with an alphanumeric maat_reference' do
    let(:maat_reference) { 'ABC123' }

    it { is_expected.not_to be_a_success }
  end

  context 'with an invalid offence_id' do
    before do
      offences_array[0][:offence_id] = 'XYZ'
    end

    it { is_expected.not_to be_a_success }
  end

  context 'with an invalid status_code' do
    before do
      offences_array[0][:status_code] = 'RGB'
    end

    it { is_expected.not_to be_a_success }
  end

  context 'with missing defence_organisation name' do
    before { defence_organisation[:organisation].delete(:name) }

    it { is_expected.not_to be_a_success }
  end

  context 'with missing laa_contract_number' do
    before { defence_organisation.delete(:laa_contract_number) }

    it { is_expected.not_to be_a_success }
  end

  context 'when missing address1' do
    before { defence_organisation[:organisation][:address].delete(:address1) }

    it { is_expected.not_to be_a_success }

    context 'and the entire address key' do
      before { defence_organisation[:organisation].delete(:address) }

      it { is_expected.to be_a_success }
    end
  end

  context 'with an invalid postcode' do
    before { defence_organisation[:organisation][:address][:postcode] = '99999' }

    it { is_expected.to be_a_success }
  end

  context 'with an invalid primary_email' do
    before { defence_organisation[:organisation][:contact][:primary_email] = '99999' }

    it { is_expected.to be_a_success }
  end

  context 'with an invalid secondary_email' do
    before { defence_organisation[:organisation][:contact][:secondary_email] = '99999' }

    it { is_expected.to be_a_success }
  end

  context 'with an invalid home phone' do
    before { defence_organisation[:organisation][:contact][:home] = 'AAABBBCCC' }

    it { is_expected.to be_a_success }
  end

  context 'with an invalid mobile phone' do
    before { defence_organisation[:organisation][:contact][:mobile] = 'AAABBBCCC' }

    it { is_expected.to be_a_success }
  end

  context 'with unexpected keys' do
    before { defence_organisation[:organisation][:contact][:additional_info] = 'Hello' }

    it { is_expected.not_to be_a_success }
  end

  let(:offences_array) do
    [
      {
        offence_id: '23d7f10a-067a-476e-bba6-bb855674e23b',
        status_code: 'AP',
        status_date: Date.new(2020, 2, 12),
        effective_start_date: Date.new(2020, 2, 20),
        effective_end_date: Date.new(2020, 2, 25)
      }
    ]
  end

  context 'Application pending status with a statusDate present' do
    it { is_expected.to be_a_success }
  end

  context 'Application pending without a statusDate' do
    before { offences_array[0][:status_date] = nil }

    it { is_expected.not_to be_a_success }
  end
end
