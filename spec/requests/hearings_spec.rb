# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Hearings', type: :request do
  describe 'POST /hearings' do
    let(:params) { JSON.parse(file_fixture('valid_hearing.json').read) }

    it 'renders a 201 status' do
      post '/hearings', params: params
      expect(response).to have_http_status(201)
    end
  end
end
