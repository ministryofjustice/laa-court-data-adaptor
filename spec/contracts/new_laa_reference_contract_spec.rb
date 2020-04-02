# frozen_string_literal: true

RSpec.describe NewLaaReferenceContract do
  subject { described_class.new.call(hash_for_validation) }

  let(:hash_for_validation) do
    {
      maat_reference: maat_reference,
      defendant_id: defendant_id
    }
  end
  let(:maat_reference) { 123_456_789 }
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }

  it { is_expected.to be_a_success }

  context 'with an alphanumeric maat_reference' do
    let(:maat_reference) { 'ABC123' }

    it { is_expected.not_to be_a_success }
  end

  context 'with an invalid defendant_id' do
    let(:defendant_id) { '23d7f10a' }

    it { is_expected.not_to be_a_success }
  end

  context 'without a maat_reference' do
    let(:hash_for_validation) do
      { defendant_id: defendant_id }
    end

    it { is_expected.to be_a_success }
  end
end
