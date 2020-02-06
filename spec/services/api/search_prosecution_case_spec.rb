# frozen_string_literal: true

RSpec.describe Api::SearchProsecutionCase do
  let(:params) { { howdy: 'hello' } }
  let(:response_status) { 200 }
  let(:search_results) { double('Response', status: response_status, body: response_body) }
  let(:response_body) { [{ 'prosecutionCaseId' => 12_345 }] }

  before do
    allow(ProsecutionCaseSearcher).to receive(:call).and_return(search_results)
  end

  subject { described_class.call(params) }

  it 'records ProsecutionCase' do
    expect(ProsecutionCaseRecorder).to receive(:call)
      .with(12_345, 'prosecutionCaseId' => 12_345)
    subject
  end

  it 'returns the recorded ProsecutionCases' do
    is_expected.to all(be_a(ProsecutionCase))
  end

  context 'containing multiple records' do
    let(:response_body) { [{ 'prosecutionCaseId' => 12_345 }, { 'prosecutionCaseId' => 23_456 }] }

    it 'records each ProsecutionCase' do
      expect(ProsecutionCaseRecorder).to receive(:call).exactly(2).times
      subject
    end
  end

  context 'containing an empty body' do
    let(:response_body) { [] }

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
