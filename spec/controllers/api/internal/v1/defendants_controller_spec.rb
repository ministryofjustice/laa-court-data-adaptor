# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe Api::Internal::V1::DefendantsController, type: :controller do
  include AuthorisedRequestHelper

  before do
    authorise_requests!

    allow(Api::Internal::V1::DefendantSerializer)
      .to receive(:new)
      .and_raise(Errors::DefendantError, "Too many maat references: [111,222]")

    allow(CommonPlatform::Api::DefendantFinder)
      .to receive(:call)
      .and_return(Defendant.new(body: {}))
  end

  context "when the CP /prosecutionCases API has `offenceSummary` having more than one `applicationReference` (maat_id)" do
    let(:defendant_id) { "501fd6c4-cc49-4ee9-b74d-4c7b30a792b6" }

    describe "GET #show" do
      it "raises HTTP 422 Unprocessable Entity" do
        get :show, params: { id: defendant_id }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("error\":\"Too many maat references: [111,222]")
      end
    end
  end
end
