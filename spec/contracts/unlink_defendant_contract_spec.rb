# frozen_string_literal: true

RSpec.describe UnlinkDefendantContract do
  subject { described_class.new.call(hash_for_validation) }

  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }

  let(:hash_for_validation) do
    { defendant_id: defendant_id }
  end

  it 'is valid' do
    expect(subject.errors).to be_empty
  end

  context 'with an invalid defendant_id' do
    let(:defendant_id) { '23d7f10a' }

    it 'is invalid' do
      expect(subject.errors).not_to be_empty
    end
  end
end
