# frozen_string_literal: true

RSpec.describe UnlinkDefendantContract do
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:user_name) { 'johnDoe' }
  let(:unlink_reason_code) { 1 }
  let(:unlink_other_reason_text) { '' }

  let(:hash_for_validation) do
    {
      defendant_id: defendant_id,
      user_name: user_name,
      unlink_reason_code: unlink_reason_code,
      unlink_other_reason_text: unlink_other_reason_text
    }
  end

  subject(:fullfillment) { described_class.new.call(hash_for_validation) }

  it { is_expected.not_to have_contract_error }

  context 'with over 10 characters in user name' do
    let(:user_name) { '12345678910' }

    it { expect(fullfillment.errors).not_to be_empty }

    it { is_expected.to have_contract_error('must not exceed 10 characters') }
  end

  context 'with a non numeric unlink_reason_code' do
    let(:unlink_reason_code) { '1' }

    it { expect(fullfillment.errors).not_to be_empty }

    it { is_expected.to have_contract_error('must be an integer') }
  end

  context 'with an invalid defendant_id' do
    let(:defendant_id) { '23d7f10a' }

    it { expect(fullfillment.errors).not_to be_empty }

    it { is_expected.to have_contract_error('not a valid uuid') }
  end

  context 'with unlink_other_reason_text present' do
    let(:unlink_other_reason_text) { 'Incorrect defendant' }

    it { is_expected.to have_contract_error('must be absent') }
  end

  context 'with unlink_reason_code for \'Other\'' do
    let(:unlink_reason_code) { 7 }

    context 'with unlink_other_reason_text present' do
      let(:unlink_other_reason_text) { 'Incorrect defendant' }

      it { is_expected.not_to have_contract_error }
    end

    context 'with unlink_other_reason_text absent' do
      let(:unlink_other_reason_text) { '' }

      it { is_expected.to have_contract_error('must be present') }
    end
  end
end
