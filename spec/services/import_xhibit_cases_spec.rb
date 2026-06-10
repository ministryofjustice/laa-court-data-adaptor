require "rails_helper"

RSpec.describe ImportXhibitCases do
  subject(:result) { described_class.call(file_path: file_fixture("xhibit_cases_import.csv")) }

  it "imports all rows from the CSV" do
    expect { result }.to change(XhibitMigratedCase, :count).by(3)
  end

  it "returns success_count and errors keys" do
    expect(result).to match(success_count: Integer, errors: Array)
  end

  context "with invalid defendant_date_of_birth format" do
    subject(:result) { described_class.call(file_path: file_fixture("xhibit_cases_import_with_errors.csv")) }

    it "reports the row with invalid date as an error" do
      date_error = result[:errors].find { |e| e[:case_urn] == "20GD0217102" }
      expect(date_error).to include(
        line_number: 5,
        case_urn: "20GD0217102",
        row: hash_including("case_urn" => "20GD0217102"),
      )
      expect(date_error[:messages]).to include("Defendant date of birth is invalid. Expected format: YYYY-MM-DD")
    end
  end

  context "with missing required fields" do
    subject(:result) { described_class.call(file_path: file_fixture("xhibit_cases_import_with_errors.csv")) }

    it "reports a missing defendant first name as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001001" }
      expect(error).to include(line_number: 6, case_urn: "30GD0001001")
      expect(error[:messages]).to include("Defendant first name can't be blank")
    end

    it "reports a missing defendant last name as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001002" }
      expect(error).to include(line_number: 7, case_urn: "30GD0001002")
      expect(error[:messages]).to include("Defendant last name can't be blank")
    end

    it "reports a missing OU code as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001003" }
      expect(error).to include(line_number: 8, case_urn: "30GD0001003")
      expect(error[:messages]).to include("Ou code can't be blank")
    end

    it "reports a missing defendant ID as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001008" }
      expect(error).to include(line_number: 13, case_urn: "30GD0001008")
      expect(error[:messages]).to include("Defendant can't be blank")
    end

    it "reports a missing court name as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001009" }
      expect(error).to include(line_number: 14, case_urn: "30GD0001009")
      expect(error[:messages]).to include("Court name can't be blank")
    end

    it "reports an invalid committal date format as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001011" }
      expect(error).to include(line_number: 16, case_urn: "30GD0001011")
      expect(error[:messages]).to include("Committal date is invalid. Expected format: YYYY-MM-DD")
    end

    it "reports an invalid sent date format as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001012" }
      expect(error).to include(line_number: 17, case_urn: "30GD0001012")
      expect(error[:messages]).to include("Sent date is invalid. Expected format: YYYY-MM-DD")
    end

    it "reports missing committal and sent dates as an error" do
      error = result[:errors].find { |e| e[:case_urn] == "30GD0001010" }
      expect(error).to include(line_number: 15, case_urn: "30GD0001010")
      expect(error[:messages]).to include("Committal date or sent date must be present")
    end
  end

  describe "mapped attributes" do
    before do
      described_class.call(file_path: file_fixture("xhibit_cases_import.csv"))
    end

    let(:first_case) { XhibitMigratedCase.find_by(case_urn: "20GD0217100") }

    it "maps string fields correctly" do
      expect(first_case).to have_attributes(
        xhibit_case_number: "T20254007",
        court_name: "Derby Justice Centre",
        ou_code: "B30PI00",
        case_type: "T",
        case_sub_type: "Either way offence",
        mode_of_trial: "Either way",
        defendant_first_name: "John",
        defendant_middle_name: nil,
        defendant_last_name: "Yundt",
        defendant_arrest_summons_number: "XVITYX8RAIHZ",
      )
    end

    it "parses date fields correctly" do
      expect(first_case).to have_attributes(
        defendant_date_of_birth: Date.new(1987, 5, 21),
        sent_date: Date.new(2019, 10, 25),
        committal_date: nil,
      )
    end
  end
end
