require "rails_helper"

RSpec.describe ImportXhibitCases do
  subject(:import) { described_class.call(file_path: file_fixture("xhibit_cases_import.csv")) }

  it "imports all rows from the CSV" do
    expect { import }.to change(XhibitCase, :count).by(3)
  end

  it "returns inserted and errors keys" do
    expect(import).to match(inserted: Array, errors: Array)
  end

  describe "mapped attributes" do
    before { import }

    let(:first_case) { XhibitCase.find_by(case_urn: "20GD0217100") }

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
