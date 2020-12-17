# frozen_string_literal: true

RSpec.describe HearingEventRecording, type: :model do
  subject { hearing_event_recording }

  let(:hearing_event_recording) { described_class.new(body: "{}") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
  end
end
