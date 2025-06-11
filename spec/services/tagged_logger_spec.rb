require "rails_helper"

RSpec.describe TaggedLogger do
  before do
    allow(Current).to receive(:request_id).and_return "<request id>"
  end

  context "when making arg-based log requests" do
    before do
      allow(Rails.logger).to receive(:info)
    end

    it "passes on arg-based log requests to request logger" do
      described_class.info "FOO"
      expect(Rails.logger).to have_received(:info).with "(Request ID: <request id>) FOO"
    end
  end

  context "when making block-based log requests" do
    before do
      allow(Rails.logger).to receive(:info)
    end

    it "passes on arg-based log requests to request logger" do
      described_class.info { "FOO" }
      expect(Rails.logger).to have_received(:info).with "(Request ID: <request id>) FOO"
    end
  end
end
