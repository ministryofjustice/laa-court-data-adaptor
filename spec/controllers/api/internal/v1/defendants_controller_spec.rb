# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe Api::Internal::V1::DefendantsController, type: :controller do
  include AuthorisedRequestHelper

  before do
    authorise_requests!

    stub_common_platform_prosecution_cases_api

    # This call creates the ProsecutionCase and ProsecutionCaseDefendantOffence
    # in the CDA DB, which are currently required to query the defendant by id
    # on this api endpoint.
    # It implies that defendants are not queryable unless their case has been searched
    # for beforehand, which seems risky (albeit that VCD should always have queried the
    # case first via its searchinng options).
    CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference:)
  end

  context "when the CP /prosecutionCases API has `offenceSummary` having more than one `applicationReference` (maat_id)" do
    let(:defendant_id) { "501fd6c4-cc49-4ee9-b74d-4c7b30a792b6" }
    let(:maat_reference) { "1234567" }

    # This case contain a `offenceSummary` having more than one applicationReference
    let(:prosecution_case_reference) { "44PC1234567" }

    describe "GET #show" do
      it "uses the canonical MAAT ID" do
        LaaReference.create!(defendant_id:, maat_reference:, user_name: "foo")
        get :show, params: { id: defendant_id }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig("data", "attributes", "maat_reference")).to eq "1234567"
      end
    end
  end

  def stub_common_platform_prosecution_cases_api
    stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/prosecutionCases?prosecutionCaseReference=#{prosecution_case_reference}")
      .to_return(
        status: 200,
        headers: { content_type: "application/json" },
        body: file_fixture("prosecution_case/offence_with_many_application_ref.json").read,
      )
  end
end
