# frozen_string_literal: true

RSpec.describe MaatApi::MaatReferenceValidator do
  subject { described_class.call(maat_reference: maat_reference) }

  let(:maat_reference) { 5_635_424 }

  it 'validates a maat_reference' do
    VCR.use_cassette('maat_api/maat_reference_success', tag: :maat_api) do
      expect(subject.status).to eq(200)
      expect(subject.body).to be_empty
    end
  end

  context 'invalid maat_reference' do
    let(:maat_reference) { 5_635_423 }

    it 'returns an error message' do
      VCR.use_cassette('maat_api/maat_reference_invalid', tag: :maat_api) do
        expect(subject.status).to eq(400)
        expect(subject.body['message']).to eq('5635423: MaatId already linked to the application.')
      end
    end
  end
end
