RSpec.describe CourtApplicationLaaReferenceBackfiller do
  subject(:result) { described_class.call(apply:) }

  let(:apply) { true }
  let(:subject_id) { SecureRandom.uuid }
  let(:court_application_id) { SecureRandom.uuid }

  let!(:laa_reference) { create(:laa_reference, defendant_id: subject_id, maat_reference: "1234567") }

  before { CourtApplication.create!(id: court_application_id, subject_id:, body: { "applicationId" => court_application_id }) }

  context "when the reference is on a court application subject id" do
    it "sets the court application id" do
      expect { result }.to change { laa_reference.reload.court_application_id }.from(nil).to(court_application_id)
    end

    it "returns the MAAT references to update" do
      expect(result).to eq({ to_update: %w[1234567], skipped: [] })
    end

    context "with a dry run" do
      let(:apply) { false }

      it "does not update the reference" do
        expect { result }.not_to(change { laa_reference.reload.court_application_id })
      end
    end
  end

  context "when the subject id is also a prosecution case defendant id" do
    before do
      prosecution_case = create(:prosecution_case, body: { "prosecutionCaseReference" => "22FA1039626" })
      create(:prosecution_case_defendant_offence, prosecution_case_id: prosecution_case.id, defendant_id: subject_id)
    end

    it "does not update the reference" do
      expect { result }.not_to(change { laa_reference.reload.court_application_id })
    end

    it "returns the MAAT references skipped" do
      expect(result).to eq({ to_update: [], skipped: %w[1234567] })
    end
  end
end
