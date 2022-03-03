# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe HearingsCreatorWorker, type: :worker do
  subject(:work) do
    described_class.perform_async("XYZ", { "data" => "some data" })
  end

  it "queues the job" do
    expect { work }.to change(described_class.jobs, :size).by(1)
  end

  it "calls HearingsCreator with a hash" do
    Sidekiq::Testing.inline! do
      expect(HearingsCreator)
        .to receive(:call)
        .once
        .with(
          hearing_resulted_data: { "data" => "some data" },
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      work
    end
  end

  it "sets the request_id on the Current singleton" do
    Sidekiq::Testing.inline! do
      expect(Current).to receive(:set).with(request_id: "XYZ")
      work
    end
  end
end
