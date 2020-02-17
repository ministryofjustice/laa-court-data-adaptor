# frozen_string_literal: true

module AuthorisedRequestHelper
  def authorise_requests!
    allow(controller).to receive(:doorkeeper_authorize!).and_return(true)
  end

  def valid_auth_header
    access_token = Doorkeeper::Application.create(name: 'test').access_tokens.create!
    { 'Authorization': "Bearer #{access_token.token}" }
  end
end
