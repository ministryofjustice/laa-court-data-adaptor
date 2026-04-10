require "rails_helper"
require "rake"

RSpec.describe "xhibit_cases:import" do
  subject(:run_task) { Rake::Task["xhibit_cases:import"].execute(file_path: file_fixture(csv_file)) }

  before do
    unless Rake::Task.task_defined?("xhibit_cases:import")
      Rake.application.rake_require("tasks/xhibit_cases")
      Rake::Task.define_task(:environment)
    end
  end

  after { Rake::Task["xhibit_cases:import"].reenable }

  context "with a valid CSV" do
    let(:csv_file) { "xhibit_cases_import.csv" }

    it "imports all rows" do
      expect { run_task }.to change(XhibitCase, :count).by(3)
    end

    it "outputs a success line for each inserted row" do
      expect { run_task }.to output(/\[OK/).to_stdout
    end

    it "outputs the summary with 3 inserted and 0 errors" do
      expect { run_task }.to output(/Import completed — 3 inserted, 0 error\(s\)/).to_stdout
    end
  end

  context "with a CSV containing invalid rows" do
    let(:csv_file) { "xhibit_cases_import_with_errors.csv" }

    it "imports only valid rows" do
      expect { run_task }.to change(XhibitCase, :count).by(1)
    end

    it "outputs a success line for the inserted row" do
      expect { run_task }.to output(/\[OK.*Line 4.*case_urn: 20GD0217101/m).to_stdout
    end

    it "outputs the error for the row missing case_urn" do
      expect { run_task }.to output(/\[ERROR.*Line 2 \(case_urn: \): Case urn can't be blank/).to_stdout
    end

    it "outputs the error for the row missing defendant_last_name" do
      expect { run_task }.to output(/\[ERROR.*Line 3 \(case_urn: 29GD7216523\): Defendant last name can't be blank/).to_stdout
    end

    it "outputs the summary with 1 inserted and 2 errors" do
      expect { run_task }.to output(/Import completed — 1 inserted, 2 error\(s\)/).to_stdout
    end
  end
end
