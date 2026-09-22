# frozen_string_literal: true

RSpec.describe CourtApplicationRecorder do
  subject(:record) { described_class.call(court_application_id, model) }

  let(:body) { JSON.parse(file_fixture("court_application_summary.json").read) }
  let(:model) { HmctsCommonPlatform::CourtApplicationSummary.new(body) }

  let(:court_application_id) { model.application_id }
  let(:defendant_id) { model.subject_summary.subject_id }
  let(:offence_id) { model.subject_summary.offence_summary.first.offence_id }

  it "creates a Court Application" do
    expect {
      record
    }.to change(CourtApplication, :count).by(1)
  end

  it "returns the created Court Application" do
    expect(record).to be_a(CourtApplication)
  end

  it "saves the body on the Court Application" do
    expect(record.body).to eq(body)
  end

  context "when the Court Application exists" do
    let!(:court_application) do
      CourtApplication.create!(
        id: court_application_id,
        subject_id: defendant_id,
        body: "old body",
      )
    end

    it "does not create a new record" do
      expect {
        record
      }.not_to change(CourtApplication, :count)
    end

    it "updates Court Application with new response" do
      record
      expect(court_application.reload.body).to eq(body)
    end
  end

  context "when another Court Application has the same subject_id" do
    let(:other_court_application_id) { SecureRandom.uuid }

    before do
      CourtApplication.create!(
        id: other_court_application_id,
        subject_id: defendant_id,
        body: "other body",
      )
      allow(Sentry).to receive(:capture_message)
    end

    it "warns Sentry" do
      record
      expect(Sentry).to have_received(:capture_message).with(
        "CourtApplicationRecorder - Subject ID #{defendant_id} of court application #{court_application_id} is already recorded on court application(s) #{other_court_application_id}",
        level: :warning,
      )
    end

    it "still creates the Court Application" do
      expect {
        record
      }.to change(CourtApplication, :count).by(1)
    end
  end

  context "when no other Court Application has the same subject_id" do
    before { allow(Sentry).to receive(:capture_message) }

    it "does not warn Sentry" do
      record
      expect(Sentry).not_to have_received(:capture_message)
    end
  end
end
