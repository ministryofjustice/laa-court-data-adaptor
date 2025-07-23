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
end
