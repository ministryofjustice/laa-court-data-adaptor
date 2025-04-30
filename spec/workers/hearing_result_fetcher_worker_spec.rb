# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe HearingResultFetcherWorker, type: :worker do
  subject(:fetch_hearing_result) do
    described_class.perform_async(
      "XYZ",
      "99c753e2-9c89-4c1a-b191-4f73084721b4",
      "2022-11-05",
      nil,
    )
  end

  it "enqueues the job" do
    expect { fetch_hearing_result }.to change(described_class.jobs, :size).by(1)
  end

  it "sets the request_id on the Current singleton" do
    Sidekiq::Testing.inline! do
      expect(Current).to receive(:set).with(request_id: "XYZ")
      fetch_hearing_result
    end
  end

  it "calls HearingResultFetcher with the expected parameters" do
    allow(HearingResultFetcher).to receive(:call)

    Sidekiq::Testing.inline! do
      expect(HearingResultFetcher)
        .to receive(:call)
        .once
        .with(
          "99c753e2-9c89-4c1a-b191-4f73084721b4",
          nil,
        )

      fetch_hearing_result
    end
  end
end
