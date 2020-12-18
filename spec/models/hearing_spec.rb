# frozen_string_literal: true

RSpec.describe Hearing, type: :model do
  subject { hearing }

  let(:hearing) { described_class.new(body: "{}") }

  it { is_expected.to validate_presence_of(:body) }

  context "when searching common platform" do
    before do
      allow(HearingsCreatorWorker).to receive(:perform_async)
    end

    context "with basic hearing data available" do
      let(:hearing_id) { "4d01840d-5959-4539-a450-d39f57171036" }
      let(:hearing) do
        VCR.use_cassette("hearing_result_fetcher/success") do
          Api::GetHearingResults.call(hearing_id: hearing_id)
        end
      end

      it { expect(hearing.id).to eq("4d01840d-5959-4539-a450-d39f57171036") }
      it { expect(hearing.court_name).to eq("Lavender Hill Magistrates' Court") }
      it { expect(hearing.hearing_type).to eq("First hearing") }
      it { expect(hearing.judge_names).to be_blank }
      it { expect(hearing.defendant_names).to eq(["Kole Jaskolski"]) }
      it { expect(hearing.prosecution_advocate_names).to be_blank }
      it { expect(hearing.defence_advocate_names).to be_blank }
      it { expect(hearing.providers).to be_blank }
      it { expect(hearing.provider_ids).to be_blank }
      it { expect(hearing.hearing_days).to eq(["2020-08-17T09:01:01.001Z"]) }
      it { expect(hearing.cracked_ineffective_trial).to be_nil }
      it { expect(hearing.cracked_ineffective_trial_id).to be_nil }

      context "with hearing events" do
        let(:hearing_day) { "2020-08-17" }

        let(:hearing_event_recording) do
          VCR.use_cassette("hearing_logs_fetcher/success") do
            Api::GetHearingEvents.call(hearing_id: hearing_id, hearing_date: hearing_day)
          end
        end

        let(:hearing_events) { [hearing_event_recording] }

        before do
          allow(Api::GetHearingEvents).to receive(:call).and_return(hearing_events)
        end

        it { expect(hearing.hearing_events).to all be_a(HearingEvent) }

        context "with blank hearing events" do
          let(:hearing_events) { [hearing_event_recording, nil] }

          it { expect(hearing.hearing_events).to all be_a(HearingEvent) }
        end
      end
    end

    context "with most hearing data available" do
      let(:hearing_id) { "29b73d8f-7683-4e27-9069-f7a031672c35" }
      let(:hearing) do
        VCR.use_cassette("hearing_result_fetcher/success_hearing_attendees") do
          Api::GetHearingResults.call(hearing_id: hearing_id)
        end
      end

      it { expect(hearing.id).to eq("29b73d8f-7683-4e27-9069-f7a031672c35") }
      it { expect(hearing.hearing_type).to eq("Committal for Sentence") }
      it { expect(hearing.court_name).to eq("Liverpool Crown Court") }
      it { expect(hearing.judge_names).to eq(["Andrew Gwyn Menary"]) }
      it { expect(hearing.defendant_names).to eq(["Trever Glover"]) }
      it { expect(hearing.prosecution_advocate_names).to eq(["andrew smith"]) }
      it { expect(hearing.defence_advocate_names).to eq(["joe bloggs"]) }
      it { expect(hearing.providers).to all be_a(Provider) }
      it { expect(hearing.provider_ids).to eq(%w[536abfd5-8671-4672-bf33-aa54de5d6a24]) }
      it { expect(hearing.hearing_days).to eq(["2020-08-18T09:00:00.000Z"]) }

      context "when prosecutionCounsels are not provided" do
        before { hearing.body["hearing"].delete("prosecutionCounsels") }

        it { expect(hearing.prosecution_advocate_names).to be_nil }
      end

      context "when defenceCounsels are not provided" do
        before { hearing.body["hearing"].delete("defenceCounsels") }

        it { expect(hearing.defence_advocate_names).to be_nil }
      end
    end
  end
end
