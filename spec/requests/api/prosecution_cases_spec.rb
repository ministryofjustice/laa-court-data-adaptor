# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::ProsecutionCases', type: :request do
  describe 'GET /api/prosecution_cases' do
    around do |example|
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        example.run
      end
    end

    let(:valid_query_params) { { filter: { prosecution_case_reference: 'TFL12345' } } }
    let(:schema) { File.read('schema/schema.json') }

    it 'matches the given schema' do
      get api_prosecution_cases_path, params: valid_query_params
      expect(response.body).to be_valid_against_schema(schema: schema)
      expect(response).to have_http_status(200)
    end
  end
end
