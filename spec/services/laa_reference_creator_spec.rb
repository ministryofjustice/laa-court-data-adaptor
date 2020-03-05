# frozen_string_literal: true

RSpec.describe LaaReferenceCreator do
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:maat_reference) { 314_159_265 }
  let(:params_hash) do
    { maat_reference: maat_reference, defendant_id: defendant_id }
  end

  subject { described_class.call(maat_reference: maat_reference, defendant_id: defendant_id) }

  it 'validates the payload' do
    expect(subject.errors).to be_blank
  end

  context 'with a non-numeric maat_reference' do
    let(:maat_reference) { 'ABC123123' }

    it 'raises errors against the payload' do
      expect(subject.errors).not_to be_blank
    end
  end
end
