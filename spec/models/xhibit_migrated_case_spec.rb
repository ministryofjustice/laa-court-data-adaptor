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
      sent_date: Date.new(2019, 10, 25),
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:xhibit_case_number) }
    it { is_expected.to validate_presence_of(:case_type) }
    it { is_expected.to validate_presence_of(:court_name) }
    it { is_expected.to validate_presence_of(:ou_code) }
    it { is_expected.to validate_presence_of(:defendant_id) }
    it { is_expected.to validate_presence_of(:defendant_first_name) }
    it { is_expected.to validate_presence_of(:defendant_last_name) }

    it {
      expect(migrated_case).to validate_uniqueness_of(:case_urn)
        .scoped_to(:defendant_first_name, :defendant_last_name)
        .with_message("is invalid: URN 20GD021701 and Defendant John Doe is already present")
    }

    context "when the same case_urn, defendant_first_name and defendant_last_name already exists" do
      before { described_class.create!(valid_attributes) }

      it "is invalid" do
        expect(migrated_case).not_to be_valid
        expect(migrated_case.errors[:case_urn]).to include("is invalid: URN 20GD021701 and Defendant John Doe is already present")
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

    context "when case_urn is nil" do
      before { described_class.create!(valid_attributes.merge(case_urn: nil, xhibit_case_number: "T202540002")) }

      it "skips uniqueness check and is valid" do
        expect(described_class.new(valid_attributes.merge(case_urn: nil))).to be_valid
      end
    end

    context "when status is set to auto_linked" do
      subject(:migrated_case) { described_class.new(valid_attributes.merge(status: "auto_linked")) }

      it { is_expected.to validate_presence_of(:maat_id) }
      it { is_expected.to validate_presence_of(:linked_at) }
      it { is_expected.to validate_presence_of(:linked_by) }
    end

    context "when status is set to `manually_linked`" do
      subject(:migrated_case) { described_class.new(valid_attributes.merge(status: "manually_linked")) }

      it { is_expected.to validate_presence_of(:maat_id) }
      it { is_expected.to validate_presence_of(:linked_at) }
      it { is_expected.to validate_presence_of(:linked_by) }
    end
  end

  describe "#trial?" do
    subject(:trial?) { described_class.new(case_type:).trial? }

    context "when case is a trial" do
      let(:case_type) { "T" }

      it { is_expected.to be(true) }
    end

    context "when case is not a trial" do
      let(:case_type) { "S" }

      it { is_expected.to be(false) }
    end
  end

  describe "#reason_for_manual_linking" do
    let(:xhibit_case) { create(:xhibit_migrated_case, status: :action_required, process_errors:) }

    context "when MAAT application not found" do
      let(:process_errors) { { "maat" => { "message" => "MAAT application not found" } } }

      it "returns user-friendly reason" do
        expect(xhibit_case.reason_for_manual_linking).to eq("MAAT application not found for this defendant")
      end
    end

    context "when MAAT ID already linked" do
      let(:process_errors) do
        { "maat" => { "message" => "MAAT ID already linked with other CP case (case_urn_123)" } }
      end

      it "returns user-friendly reason" do
        expect(xhibit_case.reason_for_manual_linking).to eq("MAAT record is linked to another court case")
      end
    end

    context "when MAAT link status unknown" do
      let(:process_errors) { { "maat" => { "message" => "MAAT link status could not be determined" } } }

      it "returns user-friendly reason" do
        expect(xhibit_case.reason_for_manual_linking).to eq("Cannot verify MAAT record status—manual review needed")
      end
    end

    context "when case not found on CP" do
      let(:process_errors) { { "common_platform" => { "message" => "Case not found on Common Platform" } } }

      it "returns user-friendly reason" do
        expect(xhibit_case.reason_for_manual_linking).to eq("Case not found on Common Platform")
      end
    end

    context "when error is technical (MAAT HTTP error)" do
      let(:process_errors) { { "maat" => { "error" => 500, "message" => "Internal Server Error" } } }

      it "returns nil (don't show to caseworkers)" do
        expect(xhibit_case.reason_for_manual_linking).to be_nil
      end
    end

    context "when process_errors is nil" do
      let(:process_errors) { nil }

      it "returns nil" do
        expect(xhibit_case.reason_for_manual_linking).to be_nil
      end
    end

    context "when status is not action_required" do
      let(:process_errors) { { "maat" => { "message" => "MAAT application not found" } } }

      before { xhibit_case.update!(status: :pending) }

      it "still returns the reason (for consistency)" do
        expect(xhibit_case.reason_for_manual_linking).to eq("MAAT application not found for this defendant")
      end
    end
  end

  describe "#as_json" do
    let(:xhibit_case) { create(:xhibit_migrated_case, case_urn:, defendant_id:, status: :action_required) }
    let(:case_urn) { "61GD7528225" }
    let(:defendant_id) { "cfc4281f-cdea-494d-8179-3173d30736fd" }

    context "when case has an actionable error" do
      before do
        xhibit_case.update!(
          process_errors: { "maat" => { "message" => "MAAT application not found", "actionable" => true } },
        )
      end

      it "includes all model fields" do
        json = xhibit_case.as_json
        expect(json).to include(
          "id" => xhibit_case.id,
          "case_urn" => case_urn,
          "defendant_id" => defendant_id,
          "status" => "action_required",
        )
      end

      it "includes reason_for_manual_linking field" do
        json = xhibit_case.as_json
        expect(json).to have_key("reason_for_manual_linking")
        expect(json["reason_for_manual_linking"]).to eq("MAAT application not found for this defendant")
      end
    end

    context "when case has no actionable error" do
      before do
        xhibit_case.update!(
          process_errors: { "maat" => { "error" => 500, "message" => "Internal Server Error" } },
        )
      end

      it "includes reason_for_manual_linking as nil" do
        json = xhibit_case.as_json
        expect(json).to have_key("reason_for_manual_linking")
        expect(json["reason_for_manual_linking"]).to be_nil
      end
    end

    context "when case has no process_errors" do
      it "includes reason_for_manual_linking as nil" do
        xhibit_case.update!(process_errors: nil)
        json = xhibit_case.as_json
        expect(json).to have_key("reason_for_manual_linking")
        expect(json["reason_for_manual_linking"]).to be_nil
      end
    end

    context "with custom options" do
      before do
        xhibit_case.update!(
          process_errors: { "maat" => { "message" => "MAAT application not found", "actionable" => true } },
        )
      end

      it "respects the except option" do
        json = xhibit_case.as_json(except: [:id])
        expect(json).not_to have_key("id")
        expect(json).to have_key("reason_for_manual_linking")
      end

      it "respects the only option" do
        json = xhibit_case.as_json(only: %i[case_urn status reason_for_manual_linking])
        expect(json).to have_key("case_urn")
        expect(json).to have_key("status")
        expect(json).to have_key("reason_for_manual_linking")
        expect(json).not_to have_key("id")
      end
    end
  end
end
