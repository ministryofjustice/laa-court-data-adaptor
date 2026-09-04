require "rails_helper"

RSpec.describe "xhibit_cases:process task" do
  subject(:process_task) { Rake::Task["xhibit_cases:process"].execute }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    allow($stdout).to receive(:puts)
    allow(ProcessXhibitCases).to receive(:call)
  end

  after { Rake::Task["xhibit_cases:process"].reenable }

  context "with pending and already-linked cases" do
    before do
      create(:xhibit_migrated_case)
      create(:xhibit_migrated_case, suffix: 2)
      create(:xhibit_migrated_case, :auto_linked, suffix: 3)

      process_task
    end

    it "hands the processing over to ProcessXhibitCases" do
      expect(ProcessXhibitCases).to have_received(:call).once
    end

    it "reports the pending count, ignoring the linked case" do
      expect($stdout).to have_received(:puts).with(/Processing 2 pending XHIBIT case/)
    end

    it "reports completion" do
      expect($stdout).to have_received(:puts).with(/Processing completed/)
    end
  end
end
