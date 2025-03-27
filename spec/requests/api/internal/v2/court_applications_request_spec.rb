# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/court_applications", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:court_application_id) { SecureRandom.uuid }

  describe "GET /api/internal/v2/court_applications/{court_application_id}" do
    before do
      stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/applications/#{court_application_id}")
        .to_return(
          status:,
          headers: { content_type: "application/json" },
          body:,
        )
      get "/api/internal/v2/court_applications/#{court_application_id}", headers: { "Authorization" => "Bearer #{token.token}" }
    end

    context "when HMCTS request is successful" do
      let(:status) { 200 }
      let(:body) { file_fixture("court_application_summary.json").read }

      it "returns 200 success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns payload" do
        expect(response.parsed_body["application_id"]).to eq("00004c9f-af9f-401a-b88b-78a4f0e08163")
      end

      it "persists a 'prosecution_case'" do
        expect(ProsecutionCase.find_by(id: court_application_id)).not_to be_nil
      end
    end

    context "when HMCTS request is unsuccessful" do
      let(:status) { 500 }
      let(:body) { { message: "uh-oh" }.to_json }

      it "returns 503 error" do
        expect(response).to have_http_status(:service_unavailable)
      end

      it "returns messaging" do
        expect(response.parsed_body["message"]).to eq("uh-oh")
      end
    end

    context "when HMCTS cannot find application" do
      let(:status) { 404 }
      let(:body) { "" }

      it "returns 404 error" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
