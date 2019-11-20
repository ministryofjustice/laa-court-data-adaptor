# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::SearchProsecutionCase do
  subject(:search) { described_class.call(prosecution_case_reference) }

  let(:prosecution_case_reference) { 'prosecution-case-ref-1234' }
  let(:prosecution_case_id) { 'prosecution-case-id-1234' }

  let(:response) do
    double(
      body: { prosecutionCases: [
        { prosecutionCaseReference: prosecution_case_reference,
          prosecutionCaseId: prosecution_case_id }
      ] }.to_json,
      status: 200
    )
  end

  before do
    allow(ProsecutionCaseSearcher).to receive(:call)
      .with(prosecution_case_reference)
      .and_return(response)
  end

  it 'calls the Prosecution Case Recorder service' do
    body = JSON.parse(response.body)
    expect(ProsecutionCaseRecorder).to receive(:call)
      .with(prosecution_case_id, body['prosecutionCases'].first)
    search
  end

  context 'when the search returns a 404 status' do
    let(:response) { double(body: {}.to_json, status: 404) }

    it 'does not record the result' do
      expect(HearingRecorder).not_to receive(:call)
      search
    end
  end
end
