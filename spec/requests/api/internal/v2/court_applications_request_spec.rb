# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/court_applications", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:court_application_id) { SecureRandom.uuid }

  describe "GET /api/internal/v2/court_applications/{court_application_id}" do
    it "return 200 succeess" do
      get "/api/internal/v2/court_applications/#{court_application_id}", headers: { "Authorization" => "Bearer #{token.token}" }

      expect(response).to have_http_status(:ok)
    end
  end
end
