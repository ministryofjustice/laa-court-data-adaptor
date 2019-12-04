# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ProsecutionCases', type: :request do
  describe 'GET /prosecution_cases' do
    let(:params) { JSON.parse(file_fixture('valid_prosecution_case_search.json').read) }

    it 'renders a 200 status' do
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        get '/prosecution_cases', params: params
        expect(response).to have_http_status(200)
      end
    end
  end
end
