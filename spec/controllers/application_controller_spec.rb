# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  include AuthorisedRequestHelper

  controller do
    def index
      head :ok
    end
  end

  let(:valid_token) { 'TOKENTOKEN' }
  let(:user) { User.create(name: 'HMCTS USER', auth_token: valid_token) }
  let(:user_id) { user.id }

  it_behaves_like 'an unauthorised request'
end
