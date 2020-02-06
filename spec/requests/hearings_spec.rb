# frozen_string_literal: true

RSpec.describe 'Hearings', type: :request do
  include AuthorisedRequestHelper

  describe 'POST /hearings' do
    let(:params) { JSON.parse(file_fixture('valid_hearing.json').read) }
    let(:user) { User.create!(name: 'LAA User', auth_token: 'TOKEN') }
    let(:headers) { valid_auth_header(user) }

    it 'renders a 201 status' do
      post '/hearings', params: params, headers: headers
      expect(response).to have_http_status(201)
    end
  end
end
