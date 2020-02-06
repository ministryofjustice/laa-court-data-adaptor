# frozen_string_literal: true

RSpec.describe ProsecutionCaseRecorder do
  let(:prosecution_case_id) { 'fa78c710-6a49-4276-bbb3-ad34c8d4e313' }
  let(:body) { { response: 'text' }.to_json }

  subject(:record) { described_class.call(prosecution_case_id, body) }

  it 'creates a Prosecution Case' do
    expect {
      record
    }.to change(ProsecutionCase, :count).by(1)
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
        body: { amazing_body: true }
      )
    end

    it 'does not create a new record' do
      expect {
        record
      }.not_to change(ProsecutionCase, :count)
    end

    it 'updates Prosecution Case with new response' do
      record
      expect(prosecution_case.reload.body).to eq(body)
    end
  end
end
