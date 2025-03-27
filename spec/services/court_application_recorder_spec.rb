# frozen_string_literal: true

RSpec.describe CourtApplicationRecorder do
  subject(:record) { described_class.call(court_application_id, model) }

  let(:body) { JSON.parse(file_fixture("court_application_summary.json").read) }
  let(:model) { HmctsCommonPlatform::CourtApplicationSummary.new(body) }

  let(:court_application_id) { model.application_id }
  let(:defendant_id) { model.subject_summary.subject_id }
  let(:offence_id) { model.subject_summary.offence_summary.first.offence_id }
  let(:prosecution_case_id) { court_application_id }

  it "creates a Prosecution Case" do
    expect {
      record
    }.to change(ProsecutionCase, :count).by(1)
  end

  it "creates a ProsecutionCaseDefendantOffence record" do
    expect {
      record
    }.to change(ProsecutionCaseDefendantOffence, :count).by(1)
  end

  it "returns the created Prosecution Case" do
    expect(record).to be_a(ProsecutionCase)
  end

  it "saves the body on the Prosecution Case" do
    expect(record.body).to eq(body)
  end

  context "when the Prosecution Case exists" do
    let!(:prosecution_case) do
      ProsecutionCase.create!(
        id: prosecution_case_id,
        body: "old body",
      )
    end

    before do
      ProsecutionCaseDefendantOffence.create!(
        prosecution_case_id:,
        defendant_id:,
        offence_id:,
        application_type: model.application_type,
      )
    end

    it "does not create a new record" do
      expect {
        record
      }.not_to change(ProsecutionCase, :count)
    end

    it "does not create a new ProsecutionCaseDefendantOffence record" do
      expect {
        record
      }.not_to change(ProsecutionCaseDefendantOffence, :count)
    end

    it "updates Prosecution Case with new response" do
      record
      expect(prosecution_case.reload.body).to eq(body)
    end
  end
end
