# frozen_string_literal: true

RSpec.describe HearingEventRecording, type: :model do
  let(:hearing_event_recording) { described_class.new(body: '{}') }
  subject { hearing_event_recording }

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end
end
