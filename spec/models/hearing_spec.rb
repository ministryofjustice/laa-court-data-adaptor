# frozen_string_literal: true

RSpec.describe Hearing, type: :model do
  let(:hearing) { described_class.new(body: '{}') }
  subject { hearing }

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'Common Platform search' do
    let(:hearing_id) { '2c24f897-ffc4-439f-9c4a-ec60c7715cd0' }

    let(:hearing) do
      VCR.use_cassette('hearing_result_fetcher/success') do
        Api::GetHearingResults.call(hearing_id: hearing_id)
      end
    end

    it { expect(hearing.court_name).to eq("Lavender Hill Magistrates' Court") }
    it { expect(hearing.hearing_type).to eq('Trial') }
    it { expect(hearing.defendant_names).to eq(['Robert Ormsby']) }

    context 'hearing events' do
      let(:hearing_day) { '2020-04-30' }

      let(:hearing_event_recording) do
        VCR.use_cassette('hearing_logs_fetcher/success') do
          Api::GetHearingEvents.call(hearing_id: hearing_id, hearing_date: hearing_day)
        end
      end

      before do
        allow(Api::GetHearingEvents).to receive(:call).and_return([hearing_event_recording])
      end

      it { expect(hearing.hearing_events).to all be_a(HearingEvent) }
    end
  end
end
