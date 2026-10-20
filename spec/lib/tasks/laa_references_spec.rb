require "rails_helper"

RSpec.describe "laa_references:backfill_court_application_id task" do
  subject(:backfill_task) { Rake::Task["laa_references:backfill_court_application_id"].execute }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    allow($stdout).to receive(:puts)
    allow(CourtApplicationLaaReferenceBackfiller).to receive(:call).and_return({ to_update: %w[1234567], skipped: %w[7647807] })
  end

  after { Rake::Task["laa_references:backfill_court_application_id"].reenable }

  context "without APPLY" do
    before { backfill_task }

    it "runs a dry run" do
      expect(CourtApplicationLaaReferenceBackfiller).to have_received(:call).with(apply: false)
    end

    it "reports the references to update and the skipped ones" do
      expect($stdout).to have_received(:puts).with(/Would update 1 LAA reference\(s\), MAAT references: 1234567/)
      expect($stdout).to have_received(:puts).with(/Skipped 1 LAA reference\(s\).*MAAT references: 7647807/)
    end
  end

  context "with APPLY=true" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("APPLY").and_return("true")

      backfill_task
    end

    it "applies the backfill" do
      expect(CourtApplicationLaaReferenceBackfiller).to have_received(:call).with(apply: true)
    end
  end
end
