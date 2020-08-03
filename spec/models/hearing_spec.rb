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
    it { expect(hearing.providers).to be_empty }
    it { expect(hearing.provider_ids).to be_empty }

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

      it { expect(hearing.judge_names).to eq(['Mr Recorder J Patterson']) }
      it { expect(hearing.prosecution_advocate_names).to eq(['John Rob']) }
      it { expect(hearing.defence_advocate_names).to eq(['Neil Griffiths']) }
      it { expect(hearing.providers).to all be_a(Provider) }
      it { expect(hearing.provider_ids).to eq(['a1e3c7a6-c6da-4191-969b-f370fcce46a8']) }
      it { expect(hearing.hearing_id).to eq('2df3d60a-3826-4099-99b0-f89e2cb5e8ec') }
      it { expect(hearing.hearing_type_description).to eq('This is a description') }
      it { expect(hearing.hearing_days).to eq(['2019-10-23T16:19:15.000Z']) }

      context 'when prosecutionCounsels are not provided' do
        before { hearing.body['hearing'].delete('prosecutionCounsels') }
        it { expect(hearing.prosecution_advocate_names).to be_nil }
      end

      context 'when defenceCounsels are not provided' do
        before { hearing.body['hearing'].delete('defenceCounsels') }
        it { expect(hearing.defence_advocate_names).to be_nil }
      end
    end
  end
end
