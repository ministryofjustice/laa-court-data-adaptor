# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  let(:valid_token) { 'TOKENTOKEN' }
  let(:user) { User.create(name: 'HMCTS USER', auth_token: valid_token) }
  let(:user_id) { user.id }

  it_behaves_like 'an unauthorised request'

  describe 'Token Authorisation' do
    let(:token) { 'FAKETOKEN' }

    before do
      request.headers.merge!('Authorization': "Bearer #{token}, user_id=#{user_id}")
    end

    describe 'invalid token' do
      it_behaves_like 'an unauthorised request'
    end

    describe 'invalid user id' do
      let(:user_id) { 'INVALID-USER-ID' }

      it_behaves_like 'an unauthorised request'
    end

    describe 'valid user id and token' do
      let(:token) { valid_token }

      it 'returns an ok status' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
