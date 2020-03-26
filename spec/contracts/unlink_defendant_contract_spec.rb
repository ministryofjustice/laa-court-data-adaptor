# frozen_string_literal: true

RSpec.describe UnlinkDefendantContract do
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:user_name) { 'johnDoe' }
  let(:unlink_reason_code) { 1 }

  let(:hash_for_validation) do
    {
      defendant_id: defendant_id,
      user_name: user_name,
      unlink_reason_code: unlink_reason_code,
      unlink_reason_text: 'Incorrect defendant'
    }
  end

  subject { described_class.new.call(hash_for_validation).errors }

  it { is_expected.to be_empty }

  context 'with over 10 characters in user name' do
    let(:user_name) { '12345678910' }

    it { is_expected.not_to be_empty }
  end

  context 'with a non numeric unlink_reason_code' do
    let(:unlink_reason_code) { 'ABC' }

    it { is_expected.not_to be_empty }
  end

  context 'with an invalid defendant_id' do
    let(:defendant_id) { '23d7f10a' }

    it { is_expected.not_to be_empty }
  end
end
