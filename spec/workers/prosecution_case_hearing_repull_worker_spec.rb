require "rails_helper"

RSpec.describe ProsecutionCaseHearingRepullWorker do
  subject(:perform) { described_class.new.perform(repull.id) }

  let(:repull) do
    ProsecutionCaseHearingRepull.create!(
      hearing_repull_batch: HearingRepullBatch.create!,
      prosecution_case:,
    )
  end
  let(:prosecution_case) do
    ProsecutionCase.create!(body: { hearingSummary: [{ hearingId: "123" }, { hearingId: "456" }] })
  end

  context "when Common Platform is called successfully" do
    before do
      allow(CommonPlatform::Api::GetHearingResults).to receive(:call)
    end

    it "calls GetHearingResults for each hearing" do
      perform
      expect(CommonPlatform::Api::GetHearingResults).to have_received(:call).exactly(2).times
    end

    it "marks the repull as complete" do
      perform
      expect(repull.reload.status).to eq "complete"
    end
  end

  context "when Common Platform errors out" do
    before do
      allow(CommonPlatform::Api::GetHearingResults).to receive(:call).and_raise(CommonPlatform::Api::Errors::FailedDependency)
    end

    it "marks the repull as failed" do
      perform
      expect(repull.reload.status).to eq "error"
    end
  end
end
