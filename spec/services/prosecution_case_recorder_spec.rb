# frozen_string_literal: true

RSpec.describe ProsecutionCaseRecorder do
  let(:prosecution_case_id) { '5edd67eb-9d8c-44f2-a57e-c8d026defaa4' }
  let(:defendant_id) { '2ecc9feb-9407-482f-b081-d9e5c8ba3ed3' }
  let(:offence_id) { '3f153786-f3cf-4311-bc0c-2d6f48af68a1' }
  let(:body) { JSON.parse(file_fixture('prosecution_case_search_result.json').read)['cases'][0] }

  subject(:record) { described_class.call(prosecution_case_id: prosecution_case_id, body: body) }

  it 'creates a Prosecution Case' do
    expect {
      record
    }.to change(ProsecutionCase, :count).by(1)
  end

  it 'creates a ProsecutionCaseDefendantOffence record' do
    expect {
      record
    }.to change(ProsecutionCaseDefendantOffence, :count).by(1)
  end

  it 'returns the created Prosecution Case' do
    expect(record).to be_a(ProsecutionCase)
  end

  it 'saves the body on the Prosecution Case' do
    expect(record.body).to eq(body)
  end

  context 'when the Prosecution Case exists' do
    let!(:prosecution_case) do
      ProsecutionCase.create!(
        id: prosecution_case_id,
        body: body
      )
    end

    let!(:prosecution_case_defendant_offence) do
      ProsecutionCaseDefendantOffence.create!(
        prosecution_case_id: prosecution_case_id,
        defendant_id: defendant_id,
        offence_id: offence_id
      )
    end

    it 'does not create a new record' do
      expect {
        record
      }.not_to change(ProsecutionCase, :count)
    end

    it 'does not create a new ProsecutionCaseDefendantOffence record' do
      expect {
        record
      }.not_to change(ProsecutionCaseDefendantOffence, :count)
    end

    it 'updates Prosecution Case with new response' do
      record
      expect(prosecution_case.reload.body).to eq(body)
    end
  end
end
