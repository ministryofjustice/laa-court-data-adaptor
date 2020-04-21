# frozen_string_literal: true

RSpec.describe Api::SearchProsecutionCase do
  let(:params) { { howdy: 'hello' } }
  let(:response_status) { 200 }
  let(:search_results) { double('Response', status: response_status, body: response_body) }
  let(:prosecution_case_id) { '5edd67eb-9d8c-44f2-a57e-c8d026defaa4' }
  let(:response_body) { JSON.parse(file_fixture('prosecution_case_search_result.json').read) }

  before do
    allow(ProsecutionCaseSearcher).to receive(:call).and_return(search_results)
  end

  subject { described_class.call(params) }

  it 'records ProsecutionCase' do
    expect(ProsecutionCaseRecorder).to receive(:call)
      .with(prosecution_case_id: prosecution_case_id, body: response_body['cases'][0])
    subject
  end

  it 'returns the recorded ProsecutionCases' do
    is_expected.to all(be_a(ProsecutionCase))
  end

  context 'containing multiple records' do
    let(:response_body) do
      {
        'totalResults' => 2,
        'cases' => [
          {
            'prosecutionCaseId' => 12_345
          },
          {
            'prosecutionCaseId' => 23_456
          }
        ]
      }
    end

    it 'records each ProsecutionCase' do
      expect(ProsecutionCaseRecorder).to receive(:call).exactly(2).times
      subject
    end
  end

  context 'containing no records' do
    let(:response_body) do
      {
        'totalResults' => 0,
        'cases' => []
      }
    end

    it 'does not record' do
      expect(ProsecutionCaseRecorder).not_to receive(:call)
      subject
    end
  end

  context 'when the response is not a 200/ok' do
    let(:response_status) { 404 }

    it 'does not record' do
      expect(ProsecutionCaseRecorder).not_to receive(:call)
      subject
    end
  end
end
