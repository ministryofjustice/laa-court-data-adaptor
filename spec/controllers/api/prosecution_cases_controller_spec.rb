# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ProsecutionCasesController, type: :controller do
  let(:valid_query_params) { { filter: { prosecution_case_reference: 'TFL12345' } } }

  describe 'GET #index' do
    it 'returns a success response' do
      allow(Api::SearchProsecutionCase).to receive(:call).and_return([])
      get :index, params: valid_query_params
      expect(response).to be_successful
    end
  end
end
