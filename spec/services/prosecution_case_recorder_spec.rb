# frozen_string_literal: true

RSpec.describe ProsecutionCaseRecorder do
  let(:prosecution_case_id) { '7a0c947e-97b4-4c5a-ae6a-26320afc914d' }
  let(:defendant_id) { '8cd0ba7e-df89-45a3-8c61-4008a2186d64' }
  let(:offence_id) { 'cacbd4d4-9102-4687-98b4-d529be3d5710' }
  let(:body) { JSON.parse(file_fixture('prosecution_case_search_result.json').read) }

  subject(:record) { described_class.call(prosecution_case_id, body) }

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
        body: JSON.parse(file_fixture('prosecution_case_search_result.json').read)
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
