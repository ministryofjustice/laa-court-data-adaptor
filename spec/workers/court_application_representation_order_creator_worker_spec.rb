# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe CourtApplicationRepresentationOrderCreatorWorker, type: :worker do
  subject(:work) do
    described_class.perform_async(request_id, subject_id, offences, maat_reference, defence_organisation)
  end

  let(:subject_id) { "LONG-UUID" }
  let(:offences) { [] }
  let(:maat_reference) { 123_123 }
  let(:defence_organisation) { { "key" => "value" } }
  let(:request_id) { "XYZ" }

  it "queues the job" do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it "creates a CommonPlatform::Api::CourtApplicationRepresentationOrderCreator and calls it" do
    Sidekiq::Testing.inline! do
      expect(CommonPlatform::Api::CourtApplicationRepresentationOrderCreator).to receive(:call).once.with(
        subject_id:,
        offences:,
        maat_reference:,
        defence_organisation:,
      ).and_call_original
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
