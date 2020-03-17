# frozen_string_literal: true

RSpec.describe 'Api::Internal::V1::ProsecutionCases', type: :request do
  include AuthorisedRequestHelper

  describe 'GET /api/internal/v1/prosecution_cases' do
    let(:headers) { valid_auth_header }

    around do |example|
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        example.run
      end
    end

    let(:valid_query_params) { { filter: { prosecution_case_reference: 'TFL12345' } } }
    let(:schema) { File.read('schema/schema.json') }

    it 'matches the given schema' do
      get api_internal_v1_prosecution_cases_path, params: valid_query_params, headers: valid_auth_header
      expect(response.body).to be_valid_against_schema(schema: schema)
      expect(response).to have_http_status(200)
    end

    context 'including defendants' do
      let(:query_with_defendants) { valid_query_params.merge(include: 'defendants') }
      it 'matches the given schema' do
        get api_internal_v1_prosecution_cases_path, params: query_with_defendants, headers: valid_auth_header
        expect(response.body).to be_valid_against_schema(schema: schema)
        expect(response).to have_http_status(200)
      end
    end

    context 'including defendants and offences' do
      let(:query_with_defendants) { valid_query_params.merge(include: 'defendants,defendants.offences') }
      it 'matches the given schema' do
        get api_internal_v1_prosecution_cases_path, params: query_with_defendants, headers: valid_auth_header
        expect(response.body).to be_valid_against_schema(schema: schema)
        expect(response).to have_http_status(200)
      end
    end
  end
end
