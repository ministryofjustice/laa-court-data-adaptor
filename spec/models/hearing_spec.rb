# frozen_string_literal: true

RSpec.describe Hearing, type: :model do
  let(:hearing) { described_class.new(body: '{}') }
  subject { hearing }

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'Common Platform search' do
    before do
      allow(HearingsCreatorWorker).to receive(:perform_async)
    end

    let(:hearing_id) { 'ee7b9c09-4a6e-49e3-a484-193dc93a4575' }

    let(:hearing) do
      VCR.use_cassette('hearing_result_fetcher/success') do
        Api::GetHearingResults.call(hearing_id: hearing_id)
      end
    end

    it { expect(hearing.court_name).to eq("Bexley Magistrates' Court") }
    it { expect(hearing.hearing_type).to eq('Plea and Trial Preparation') }
    it { expect(hearing.defendant_names).to eq(['Ocean Gagnier']) }

    context 'hearing events' do
      let(:hearing_day) { '2020-04-17' }

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

     context 'hearings information' do
       let(:hearing_id) { '2df3d60a-3826-4099-99b0-f89e2cb5e8ec' }
       let(:hearing) do

        VCR.use_cassette('hearing_result_fetcher/success_hearing_attendees') do
          Api::GetHearingResults.call(hearing_id: hearing_id)
        end
      end

      it { expect(hearing.judge_names).to eq(["Mr Recorder J Patterson"]) }
    end
  end
end
