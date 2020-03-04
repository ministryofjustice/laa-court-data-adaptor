# frozen_string_literal: true

RSpec.describe NewLaaReferenceContract do
  subject { described_class.new.call(hash_for_validation) }

  let(:hash_for_validation) do
    {
      maat_reference: maat_reference,
      defendant_id: '23d7f10a-067a-476e-bba6-bb855674e23b'
    }
  end
  let(:maat_reference) { 123_456_789 }

  it 'is valid' do
    expect(subject.errors).to be_empty
  end

  context 'with an alphanumeric maat_reference' do
    let(:maat_reference) { 'ABC123' }

    it 'is invalid' do
      expect(subject.errors).not_to be_empty
    end
  end

  context 'with a missing maat_reference' do
    let(:hash_for_validation) do
      { defendant_id: '23d7f10a-067a-476e-bba6-bb855674e23b' }
    end

    it 'is valid' do
      expect(subject.errors).to be_empty
    end
  end
end
