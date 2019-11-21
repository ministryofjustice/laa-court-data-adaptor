# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::SearchProsecutionCase do
  let(:prosecution_case_id) { 'b9950946-fe3b-4eaa-9f0a-35e497e34528' }
  let(:prosecution_case_reference) { '3658e889-e050-4608-8f21-8bdaa529f8d0' }

  let(:api_request_url) { '/prosecutionCases' }
  let(:params) do
    { prosecution_case_reference: prosecution_case_reference }
  end

  it_has_a 'correct api request url'

  context 'searching with ProsecutionCase Reference' do
    subject(:search) { described_class.call(prosecution_case_reference: prosecution_case_reference) }

    it 'calls the Prosecution Case Recorder service' do
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        expect(ProsecutionCaseRecorder).to receive(:call)
          .with(prosecution_case_id, Hash)
        search
      end
    end

    context 'with a non existent id' do
      let(:prosecution_case_reference) { 'prosecution-case-5678' }

      it 'returns a not found response' do
        VCR.use_cassette('search_prosecution_case/no_results') do
          expect(ProsecutionCaseRecorder).to_not receive(:call)
        end
      end
    end
  end

  context 'searching with National Insurance Number' do
    let(:national_insurance_number) { 'BN102966C' }

    subject(:search) { described_class.call(national_insurance_number: national_insurance_number) }

    it 'calls the Prosecution Case Recorder service' do
      VCR.use_cassette('search_prosecution_case/by_national_insurance_number_success') do
        expect(ProsecutionCaseRecorder).to receive(:call)
          .with(prosecution_case_id, Hash)
        search
      end
    end
  end
end
