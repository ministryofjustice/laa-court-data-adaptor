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

  it "creates a CourtApplicationDefendantOffence record" do
    expect {
      record
    }.to change(CourtApplicationDefendantOffence, :count).by(1)
  end

  it "returns the created Court Application" do
    expect(record).to be_a(CourtApplication)
  end

  it "saves the body on the Court Application" do
    expect(record.body).to eq(body)
  end

  context "when the Court Application exists" do
    let!(:prosecution_case) do
      CourtApplication.create!(
        id: court_application_id,
        body: "old body",
      )
    end

    before do
      CourtApplicationDefendantOffence.create!(
        court_application_id:,
        defendant_id:,
        offence_id:,
        application_type: model.application_type,
      )
    end

    it "does not create a new record" do
      expect {
        record
      }.not_to change(CourtApplication, :count)
    end

    it "does not create a new CourtApplicationDefendantOffence record" do
      expect {
        record
      }.not_to change(CourtApplicationDefendantOffence, :count)
    end

    it "updates Court Application with new response" do
      record
      expect(prosecution_case.reload.body).to eq(body)
    end
  end
end
