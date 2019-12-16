# frozen_string_literal: true

module AuthorisedRequestHelper
  def authorise_requests!
    allow(controller).to receive(:authenticate).and_return(true)
  end

  def valid_auth_header(user)
    { 'Authorization': "Bearer #{user.auth_token}, user_id=#{user.id}" }
  end
end
