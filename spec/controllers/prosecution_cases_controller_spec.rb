# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProsecutionCasesController, type: :controller do
  include AuthorisedRequestHelper

  before { authorise_requests! }

  describe 'GET #index' do
    let(:params) { JSON.parse(file_fixture('valid_prosecution_case_search.json').read) }

    it 'returns a success response' do
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        get :index, params: params
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the prosecutionCase is not found' do
      let(:params) do
        {
          "prosecutionCases": {
            "caseReference": 'prosecution-case-5678'
          }
        }
      end

      before do
        allow(ProsecutionCaseSearcher).to receive(:call).and_return(double(status: 200, body: []))
      end

      it 'returns a not found response' do
        get :index, params: params
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
