# frozen_string_literal: true

RSpec.describe Hearing, type: :model do
  context "when searching common platform" do
    before do
      allow(HearingsCreatorWorker).to receive(:perform_async)
    end

    context "with basic hearing data available" do
      let(:hearing_id) { "4d01840d-5959-4539-a450-d39f57171036" }
      let(:hearing_result_data) do
        VCR.use_cassette("hearing_result_fetcher/success") do
          CommonPlatform::Api::GetHearingResults.call(hearing_id:, sitting_day: nil)
        end
      end
      let(:hearing) { described_class.new(hearing_result_data["hearing"]) }

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
      it { expect(hearing.defendant_judicial_results).to be_blank }
      it { expect(hearing.prosecution_cases).to all(be_an(HmctsCommonPlatform::ProsecutionCase)) }

      context "with hearing events" do
        let(:hearing_event_recording) do
          VCR.use_cassette("hearing_logs_fetcher/success") do
            CommonPlatform::Api::GetHearingEvents.call(hearing_id:, hearing_date: "2020-08-17")
          end
        end

        let(:hearing_events) { [hearing_event_recording] }

        before do
          allow(CommonPlatform::Api::GetHearingEvents).to receive(:call).and_return(hearing_events)
        end

        it { expect(hearing.hearing_events).to all be_a(HearingEvent) }
        it { expect(hearing.hearing_event_ids).to eql %w[a6e53c75-7d42-4187-956a-0d1d80884832] }

        context "with blank hearing events" do
          let(:hearing_events) { [hearing_event_recording, nil] }

          it { expect(hearing.hearing_events).to all be_a(HearingEvent) }
        end

        context "with a missing events key from hearing log response" do
          let(:hearing_events) { [HearingEventRecording.new(body: {})] }

          it { expect(hearing.hearing_events).to be_empty }
        end
      end
    end

    context "with most hearing data available" do
      let(:hearing_id) { "29b73d8f-7683-4e27-9069-f7a031672c35" }
      let(:hearing_result_data) do
        VCR.use_cassette("hearing_result_fetcher/success_hearing_attendees") do
          CommonPlatform::Api::GetHearingResults.call(hearing_id:, sitting_day: nil)
        end
      end
      let(:hearing) { described_class.new(hearing_result_data["hearing"]) }

      it { expect(hearing.id).to eq("29b73d8f-7683-4e27-9069-f7a031672c35") }
      it { expect(hearing.hearing_type).to eq("Committal for Sentence") }
      it { expect(hearing.court_name).to eq("Liverpool Crown Court") }
      it { expect(hearing.judge_names).to eq(["Andrew Gwyn Menary"]) }
      it { expect(hearing.defendant_names).to eq(["Trever Glover"]) }
      it { expect(hearing.prosecution_advocate_names).to eq(["andrew smith"]) }
      it { expect(hearing.defence_advocate_names).to eq(["joe bloggs"]) }
      it { expect(hearing.providers).to all be_a(Provider) }
      it { expect(hearing.defendant_judicial_results).to all be_a(HmctsCommonPlatform::DefendantJudicialResult) }
      it { expect(hearing.provider_ids).to eq(%w[536abfd5-8671-4672-bf33-aa54de5d6a24]) }
      it { expect(hearing.hearing_days).to eq(["2020-08-18T09:00:00.000Z"]) }
      it { expect(hearing.prosecution_cases).to all(be_an(HmctsCommonPlatform::ProsecutionCase)) }

      context "when prosecutionCounsels are not provided" do
        before { hearing.data.delete("prosecutionCounsels") }

        it { expect(hearing.prosecution_advocate_names).to eql([]) }
      end

      context "when defenceCounsels are not provided" do
        before { hearing.data.delete("defenceCounsels") }

        it { expect(hearing.defence_advocate_names).to eql([]) }
      end
    end

    context "with cracked ineffective trial data available" do
      let(:hearing_id) { "da124701-048f-408c-85b4-81138316ddce" }
      let(:hearing_result_data) do
        VCR.use_cassette("hearing_result_fetcher/success_hearing_cracked_trial") do
          CommonPlatform::Api::GetHearingResults.call(hearing_id:, sitting_day: nil)
        end
      end
      let(:hearing) { described_class.new(hearing_result_data["hearing"]) }

      describe "#cracked_ineffective_trial_id" do
        subject { hearing.cracked_ineffective_trial_id }

        it { is_expected.to eql("c4ca4238-a0b9-3382-8dcc-509a6f75849b") }
      end

      describe "#cracked_ineffective_trial" do
        subject { hearing.cracked_ineffective_trial }

        it { is_expected.to be_a(CrackedIneffectiveTrial) }
        it { is_expected.to respond_to(:id, :code, :description, :type) }
      end
    end

    context "with court applications data available" do
      let(:hearing_result_data) { JSON.parse(file_fixture("hearing/with_court_application.json").read) }
      let(:hearing) { described_class.new(hearing_result_data["hearing"]) }

      describe "#court_applications" do
        subject { hearing.court_applications }

        it { is_expected.to all be_an(HmctsCommonPlatform::CourtApplication) }
      end

      describe "#court_application_ids" do
        subject { hearing.court_application_ids }

        it { is_expected.to eql(%w[c5266a93-389c-4331-a56a-dd000b361cef]) }
      end
    end
  end
end
