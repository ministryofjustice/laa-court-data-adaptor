# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an unauthorised request' do
  it 'responds with a 401 status code' do
    get :index
    expect(response).to have_http_status(:unauthorized)
  end
end
