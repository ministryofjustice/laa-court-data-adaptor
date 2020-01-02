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

  context 'authorisation check' do
    subject(:search) { Api::SearchProsecutionCase.new }

    it 'has the correct auth header' do
      VCR.use_cassette('search_prosecution_case/with_no_params_to_test_auth_header') do
        search.call
        expect(search.response.env.request_headers['Authorization']).to match(ENV['SHARED_SECRET_KEY_SEARCH_PROSECUTION_CASE'])
      end
    end
  end

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

  context 'searching with Arrest Summons Number' do
    let(:arrest_summons_number) { 'MG25A12456' }

    subject(:search) { described_class.call(arrest_summons_number: arrest_summons_number) }

    it 'calls the Prosecution Case Recorder service' do
      VCR.use_cassette('search_prosecution_case/by_arrest_summons_number_success') do
        expect(ProsecutionCaseRecorder).to receive(:call)
          .with(prosecution_case_id, Hash)
        search
      end
    end
  end

  context 'searching with name and date of birth' do
    let(:name) do
      { firstName: 'Alfredine', lastName: 'Parker' }
    end

    let(:date_of_birth) { '1971-05-12' }

    subject(:search) { described_class.call(name: name, date_of_birth: date_of_birth) }

    it 'calls the Prosecution Case Recorder service' do
      VCR.use_cassette('search_prosecution_case/by_name_and_date_of_birth_success') do
        expect(ProsecutionCaseRecorder).to receive(:call)
          .with(prosecution_case_id, Hash)
        search
      end
    end
  end

  context 'searching with name and date_of_next_hearing' do
    let(:name) do
      { firstName: 'Alfredine', lastName: 'Parker' }
    end

    let(:date_of_next_hearing) { '2025-05-04' }

    subject(:search) { described_class.call(name: name, date_of_next_hearing: date_of_next_hearing) }

    it 'calls the Prosecution Case Recorder service' do
      VCR.use_cassette('search_prosecution_case/by_name_and_date_of_next_hearing_success') do
        expect(ProsecutionCaseRecorder).to receive(:call)
          .with(prosecution_case_id, Hash)
        search
      end
    end
  end
end
