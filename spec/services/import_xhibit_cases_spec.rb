require "rails_helper"

RSpec.describe ImportXhibitCases do
  subject(:import) { described_class.call(file_path: file_fixture("xhibit_cases_import.csv")) }

  it "imports all rows from the CSV" do
    expect { import }.to change(XhibitMigratedCase, :count).by(3)
  end

  it "returns success_count and errors keys" do
    expect(import).to match(success_count: Integer, errors: Array)
  end

  context "with invalid defendant_date_of_birth format" do
    subject(:import) { described_class.call(file_path: file_fixture("xhibit_cases_import_with_errors.csv")) }

    it "reports the row with invalid date as an error" do
      result = import
      date_error = result[:errors].find { |e| e[:case_urn] == "20GD0217102" }
      expect(date_error).to include(
        line_number: 5,
        case_urn: "20GD0217102",
        row: hash_including("case_urn" => "20GD0217102"),
      )
      expect(date_error[:messages]).to include("Defendant date of birth is invalid.")
    end
    it "reports the row with no case URN as an error" do
      result = import
      urn_error = result[:errors].find { |e| e[:line_number] == 2 }
      expect(urn_error).to include(
        line_number: 2,
        case_urn: nil,
        row: hash_including("case_urn" => nil),
      )
      expect(urn_error[:messages]).to include("Case urn can't be blank")
    end
  end

  describe "mapped attributes" do
    before { import }

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
