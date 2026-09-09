require "rails_helper"

RSpec.describe TaggedLogger do
  before do
    allow(Current).to receive(:request_id).and_return "<request-id-example>"
  end

  context "when making arg-based log requests" do
    before do
      allow(Rails.logger).to receive(:info)
    end

    it "passes on arg-based log requests to request logger" do
      described_class.info "FOO"
      expect(Rails.logger).to have_received(:info).with "(Request ID: <request-id-example>) FOO"
    end
  end

  context "when making block-based log requests" do
    before do
      allow(Rails.logger).to receive(:info)
    end

    it "passes on arg-based log requests to request logger" do
      described_class.info { "FOO" }
      expect(Rails.logger).to have_received(:info).with "(Request ID: <request-id-example>) FOO"
    end
  end

  describe ".log_event" do
    before do
      allow(Rails.logger).to receive(:error)
    end

    it "logs a JSON including the event and request id" do
      described_class.log_event(:error, "some_event", status: 500, endpoint: "/foo")

      expect(Rails.logger).to have_received(:error).with(
        '{"event":"some_event","request_id":"<request-id-example>","status":500,"endpoint":"/foo"}',
      )
    end

    it "does not log nil values so they are not indexed as empty" do
      described_class.log_event(:error, "some_event", status: 500, error_message: nil)

      expect(Rails.logger).to have_received(:error).with(
        '{"event":"some_event","request_id":"<request-id-example>","status":500}',
      )
    end

    it "logs at the given level" do
      allow(Rails.logger).to receive(:warn)

      described_class.log_event(:warn, "some_event")

      expect(Rails.logger).to have_received(:warn).with(
        '{"event":"some_event","request_id":"<request-id-example>"}',
      )
    end
  end
end
