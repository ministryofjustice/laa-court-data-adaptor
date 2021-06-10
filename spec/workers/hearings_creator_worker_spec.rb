# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe HearingsCreatorWorker, type: :worker do
  subject(:work) { described_class.perform_async(request_id, hearing_resulted_data) }

  let(:hearing_resulted_data) { "some data" }
  let(:request_id) { "XYZ" }

  it "queues the job" do
    expect { work }.to change(described_class.jobs, :size).by(1)
  end

  it "creates a HearingsCreator and calls with a transformed hash" do
    Sidekiq::Testing.inline! do
      expect(HearingsCreator).to receive(:call).once.with(hearing_resulted_data: "some data")
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
