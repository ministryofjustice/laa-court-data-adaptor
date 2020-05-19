# frozen_string_literal: true

RSpec.describe Hearing, type: :model do
  let(:hearing) { described_class.new(body: '{}') }
  subject { hearing }

  describe 'validations' do
    it { should validate_presence_of(:body) }

    context 'when the body is missing' do
      before { hearing.body = nil }
      it { should validate_presence_of(:events) }
    end
  end

  describe 'Common Platform search' do
    let(:hearing_id) { 'b935a64a-6d03-4da4-bba6-4d32cc2e7fb4' }

    let(:hearing) do
      VCR.use_cassette('hearing_result_fetcher/success') do
        Api::GetHearingResults.call(hearing_id)
      end
    end

    it { expect(hearing.court_name).to eq("Bexley Magistrates' Court") }
    it { expect(hearing.hearing_type).to eq('First hearing') }
    it { expect(hearing.defendant_names).to eq(['George Walsh']) }
  end
end
