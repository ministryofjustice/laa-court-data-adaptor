# frozen_string_literal: true

RSpec.describe ReferenceData::CourtCentreFinder do
  subject(:find_row) { described_class.call(id: id) }

  let(:id) { 'a2ff05a1-1f2f-31d4-8854-a5f39f1c1478' }

  it 'returns the requested CourtCentre' do
    expect(find_row).to be_a(CSV::Row)
    expect(find_row['oucode']).to eq('A88AE00')
  end

  context 'when the CourtCentre does not exist' do
    let(:id) { 'XYZ' }

    it { is_expected.to be_nil }
  end
end
