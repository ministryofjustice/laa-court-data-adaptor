# frozen_string_literal: true

RSpec.describe ProsecutionCaseRecorder do
  subject(:record) { described_class.call(prosecution_case_id:, body:) }

  let(:prosecution_case_id) { "5edd67eb-9d8c-44f2-a57e-c8d026defaa4" }
  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:offence_id) { "3f153786-f3cf-4311-bc0c-2d6f48af68a1" }
  let(:body) { JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0] }

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
        body:,
      )
    end

    before do
      ProsecutionCaseDefendantOffence.create!(
        prosecution_case_id:,
        defendant_id:,
        offence_id:,
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

    context "when other prosecution case exists" do
      let!(:other_prosecution_case) do
        ProsecutionCase.create!(
          id: SecureRandom.uuid,
          body:,
        )
      end

      context "when this case has a PCDO (Prosecution Case Defendant Offence) for the other case's defendant" do
        let!(:case_to_be_deleted) do
          ProsecutionCaseDefendantOffence.create!(
            prosecution_case_id: other_prosecution_case.id,
            defendant_id:,
            offence_id:,
          )
        end

        it "deletes the incorrect PCDO" do
          record
          expect(ProsecutionCaseDefendantOffence.find_by(id: case_to_be_deleted.id)).to be_nil
        end
      end

      context "when the other case has a PCDO for this case's defendant" do
        let!(:case_to_be_deleted) do
          ProsecutionCaseDefendantOffence.create!(
            prosecution_case_id: prosecution_case.id,
            defendant_id: SecureRandom.uuid,
            offence_id: SecureRandom.uuid,
          )
        end

        it "deletes the incorrect PCDO" do
          record
          expect(ProsecutionCaseDefendantOffence.find_by(id: case_to_be_deleted.id)).to be_nil
        end
      end
    end
  end
end
