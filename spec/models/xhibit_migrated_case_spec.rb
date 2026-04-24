# frozen_string_literal: true

require "rails_helper"

RSpec.describe XhibitMigratedCase, type: :model do
  subject(:migrated_case) { described_class.new(valid_attributes) }

  let(:valid_attributes) do
    {
      case_urn: "20GD021701",
      xhibit_case_number: "T202540001",
      court_name: "Derby Justice Centre",
      ou_code: "B30PI00",
      case_type: "T",
      case_sub_type: "Either way offence",
      mode_of_trial: "Either way",
      defendant_id: "defendant-1",
      defendant_first_name: "John",
      defendant_last_name: "Doe",
      defendant_date_of_birth: Date.new(1987, 5, 21),
      defendant_arrest_summons_number: "ASN001",
    }
  end

  describe "validations" do
    it {
      is_expected.to validate_uniqueness_of(:case_urn)
        .scoped_to(:defendant_first_name, :defendant_last_name)
        .with_message("20GD021701, defendant: John Doe is already present")
    }

    context "when the same case_urn, defendant_first_name and defendant_last_name already exists" do
      before { described_class.create!(valid_attributes) }

      it "is invalid" do
        expect(migrated_case).not_to be_valid
        expect(migrated_case.errors[:case_urn]).to include("20GD021701, defendant: John Doe is already present")
      end
    end

    context "when case_urn is different" do
      before { described_class.create!(valid_attributes) }

      it "is valid" do
        expect(described_class.new(valid_attributes.merge(case_urn: "20GD021702"))).to be_valid
      end
    end

    context "when defendant_first_name is different" do
      before { described_class.create!(valid_attributes) }

      it "is valid" do
        expect(described_class.new(valid_attributes.merge(defendant_first_name: "Jane"))).to be_valid
      end
    end

    context "when defendant_last_name is different" do
      before { described_class.create!(valid_attributes) }

      it "is valid" do
        expect(described_class.new(valid_attributes.merge(defendant_last_name: "Smith"))).to be_valid
      end
    end
  end
end
