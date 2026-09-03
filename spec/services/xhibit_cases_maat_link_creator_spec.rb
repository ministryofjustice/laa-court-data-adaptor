RSpec.describe XhibitCasesMaatLinkCreator, type: :service do
  subject(:create_maat_link) do
    described_class.call(
      xhibit_migrated_case:,
      defendant_id:,
      user_name:,
      maat_reference:,
    )
  end

  let(:defendant_id) { SecureRandom.uuid }
  let(:user_name) { "peter-rabbit" }
  let(:maat_reference) { "1234567" }
  let(:expected_maat_reference) { maat_reference }
  let(:case_type) { "T" }
  let(:xhibit_migrated_case) { create(:xhibit_migrated_case, case_type:, defendant_id:) }

  context "when the migrated case is a trial" do
    it "calls the prosecution case link creator and updates the migrated case" do
      expect(ProsecutionCaseMaatLinkCreator)
        .to receive(:call)
        .with(defendant_id, user_name, expected_maat_reference)

      expect(CourtApplicationMaatLinkCreator).not_to receive(:call)

      create_maat_link

      expect(xhibit_migrated_case.maat_id).to eq(expected_maat_reference)
      expect(xhibit_migrated_case.status).to eq("manually_linked")
      expect(xhibit_migrated_case.linked_by).to eq(user_name)
      expect(xhibit_migrated_case.linked_at).not_to be_nil
    end
  end

  context "when the migrated case is not a trial" do
    let(:case_type) { "S" }

    it "calls the court application link creator and updates the migrated case" do
      expect(CourtApplicationMaatLinkCreator)
        .to receive(:call)
        .with(defendant_id, user_name, expected_maat_reference)

      expect(ProsecutionCaseMaatLinkCreator).not_to receive(:call)

      create_maat_link

      expect(xhibit_migrated_case.maat_id).to eq(expected_maat_reference)
      expect(xhibit_migrated_case.status).to eq("manually_linked")
      expect(xhibit_migrated_case.linked_by).to eq(user_name)
      expect(xhibit_migrated_case.linked_at).not_to be_nil
    end
  end
end
