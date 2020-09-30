# frozen_string_literal: true

RSpec.describe NewLaaReferenceContract do
  subject { described_class.new.call(hash_for_validation) }

  around do |example|
    VCR.use_cassette('maat_api/maat_reference_success') do
      example.run
    end
  end

  let(:hash_for_validation) do
    {
      maat_reference: maat_reference,
      defendant_id: defendant_id,
      user_name: user_name
    }
  end
  let(:maat_reference) { 123_456_789 }
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:user_name) { '' }

  it { is_expected.to be_a_success }

  context 'with a maat_reference cast as a string' do
    let(:maat_reference) { '123456789' }

    it { is_expected.to be_a_success }
  end

  context 'with a user_name' do
    let(:user_name) { 'johnDoe' }

    it { is_expected.to be_a_success }
  end

  context 'with over 10 characters in user name' do
    let(:user_name) { '12345678910' }

    it { is_expected.to have_contract_error('size cannot be greater than 10') }
  end

  context 'with an alphanumeric maat_reference' do
    let(:maat_reference) { 'ABC123' }

    it { is_expected.not_to be_a_success }
  end

  context 'with an invalid defendant_id' do
    let(:defendant_id) { '23d7f10a' }

    it { is_expected.not_to be_a_success }
  end

  context 'with an invalid maat_reference' do
    let(:maat_reference) { 5_635_423 }

    around do |example|
      VCR.use_cassette('maat_api/maat_reference_invalid') do
        example.run
      end
    end

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error('5635423: MaatId already linked to the application.') }
  end

  context 'without a maat_reference' do
    let(:hash_for_validation) do
      { defendant_id: defendant_id }
    end

    it { is_expected.to be_a_success }
  end
end
