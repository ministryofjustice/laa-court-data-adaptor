# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/prosecution_case", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  before do
    allow(CommonPlatform::Api::GetHearingResults).to receive(:call)
  end

  path "/api/internal/v2/prosecution_cases" do
    get("search prosecution cases") do
      description "Search prosecution cases. Valid search combinations are: <br/><br/>
                    1) prosecution_case_reference <br/>
                    2) arrest_summons_number <br/>
                    3) national_insurance_number <br/>
                    4) name and date_of_birth <br/>
                    5) name and date_of_next_hearing"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]
      parameter "$ref" => "#/components/parameters/transaction_id_header"

      context "when searching by prosecution_case_reference" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:prosecution_case_reference) { "61GD7528225" }
        let(:'filter[prosecution_case_reference]') { prosecution_case_reference }

        produces "application/vnd.api+json"

        parameter name: "filter[prosecution_case_reference]", in: :query, required: false, type: :string,
                  schema: {
                    "$ref": "prosecution_case_identifier.json#/properties/case_urn",
                  },
                  description: "Searches prosecution cases by prosecution case reference"

        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { prosecutionCaseReference: prosecution_case_reference },
              body: file_fixture("prosecution_cases_v2.json").read,
            )
          end

          schema "$ref" => "search_prosecution_case_response.json#"

          run_test!
        end

        context "when search returns no results" do
          before do
            stub_prosecution_case_search(
              query: { prosecutionCaseReference: prosecution_case_reference },
              body: { totalResults: 0, cases: [] }.to_json,
            )
          end

          response(200, "Success") do
            run_test! do |response|
              expect(response.parsed_body).to eq("total_results" => 0, "results" => [])
            end
          end
        end

        context "when Common Platform API returns an error" do
          before do
            stub_prosecution_case_search(
              query: { prosecutionCaseReference: prosecution_case_reference },
              status: 404,
              body: { error: "Not found" }.to_json,
            )
          end

          response(424, "Common Platform API Error") do
            run_test! do |response|
              expect(response.parsed_body["error_codes"]).to eq %w[common_platform_connection_failed]
            end
          end
        end

        context "when Common Platform API is offline" do
          before do
            stub_request(:get, /.*/).to_raise(Errno::ECONNREFUSED)
          end

          response(503, "Common Platform API Offline") do
            it "returns an error code" do
              get "/api/internal/v2/prosecution_cases?filter[prosecution_case_reference]=123", headers: { "Authorization" => "Bearer #{token.token}" }
              expect(response.parsed_body["error_codes"]).to eq %w[common_platform_connection_failed]
            end
          end
        end
      end

      context "when searching by arrest_summons_number" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantASN: "arrest123" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          parameter name: "filter[arrest_summons_number]", in: :query, required: false, type: :string,
                    schema: {
                      "$ref": "defendant_summary.json#/properties/arrest_summons_number",
                    },
                    description: "Searches prosecution cases by arrest summons number"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:"filter[arrest_summons_number]") { "arrest123" }

          run_test!
        end
      end

      context "when searching by national_insurance_number" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantNINO: "HB133542A" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          parameter name: "filter[national_insurance_number]", in: :query, required: false, type: :string,
                    schema: {
                      "$ref": "person.json#/properties/nino",
                    },
                    description: "Searches prosecution cases by national_insurance_number"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:"filter[national_insurance_number]") { "HB133542A" }

          run_test!
        end
      end

      context "when searching by name and date of birth" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantName: "George Walsh", defendantDOB: "1980-01-01" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          parameter name: "filter[name]", in: :query, required: false, type: :string,
                    schema: {
                      "$ref": "person.json#/properties/last_name",
                    },
                    description: "Searches prosecution cases by name"

          parameter name: "filter[date_of_birth]", in: :query, required: false, type: :string,
                    schema: {
                      "$ref": "person.json#/properties/date_of_birth",
                    },
                    description: "Searches prosecution cases by date_of_birth"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:"filter[name]") { "George Walsh" }
          let(:"filter[date_of_birth]") { "1980-01-01" }

          run_test!
        end
      end

      context "when searching by name and date of next hearing" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantName: "George Walsh", dateOfNextHearing: "2020-02-17" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          parameter name: "filter[name]", in: :query, required: false, type: :string,
                    schema: {
                      "$ref": "person.json#/properties/last_name",
                    },
                    description: "Searches prosecution cases by name"

          parameter name: "filter[date_of_next_hearing]", in: :query, required: false, type: :string,
                    schema: {
                      "$ref": "definitions.json#/definitions/datePattern",
                    },
                    description: "Searches prosecution cases by date_of_next_hearing"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:"filter[name]") { "George Walsh" }
          let(:"filter[date_of_next_hearing]") { "2020-02-17" }

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          run_test!
        end
      end
    end

    post("search prosecution cases") do
      description "Search prosecution cases. Valid search combinations are: <br/><br/>
                    1) prosecution_case_reference <br/>
                    2) arrest_summons_number <br/>
                    3) national_insurance_number <br/>
                    4) name and date_of_birth <br/>
                    5) name and date_of_next_hearing"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]
      parameter "$ref" => "#/components/parameters/transaction_id_header"
      parameter name: :filter, in: :body, required: true, type: :object,
                schema: { "$ref": "prosecution_case_post_request_body.json#" }
      produces "application/vnd.api+json"

      let(:Authorization) { "Bearer #{token.token}" }

      context "when searching by prosecution_case_reference" do
        let(:prosecution_case_reference) { "61GD7528225" }
        let(:filter) { { filter: { prosecution_case_reference: } } }

        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { prosecutionCaseReference: prosecution_case_reference },
              body: file_fixture("prosecution_cases_v2.json").read,
            )
          end

          schema "$ref" => "search_prosecution_case_response.json#"

          run_test!
        end

        context "when search returns no results" do
          before do
            stub_prosecution_case_search(
              query: { prosecutionCaseReference: prosecution_case_reference },
              body: { totalResults: 0, cases: [] }.to_json,
            )
          end

          response(200, "Success") do
            run_test! do |response|
              expect(response.parsed_body).to eq("total_results" => 0, "results" => [])
            end
          end
        end

        context "when Common Platform API returns an error" do
          before do
            stub_prosecution_case_search(
              query: { prosecutionCaseReference: prosecution_case_reference },
              status: 404,
              body: { error: "Not found" }.to_json,
            )
          end

          response(424, "Common Platform API Error") do
            run_test! do |response|
              expect(response.parsed_body["error_codes"]).to eq %w[common_platform_connection_failed]
            end
          end
        end

        context "when Common Platform API is offline" do
          before do
            stub_request(:get, /.*/).to_raise(Errno::ECONNREFUSED)
          end

          response(503, "Common Platform API Offline") do
            it "returns an error code" do
              post "/api/internal/v2/prosecution_cases", params: { filter: { prosecution_case_reference: 123 } }, headers: { "Authorization" => "Bearer #{token.token}" }
              expect(response.parsed_body["error_codes"]).to eq %w[common_platform_connection_failed]
            end
          end
        end
      end

      context "when searching by arrest_summons_number" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantASN: "arrest123" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          let(:filter) { { filter: { arrest_summons_number: "arrest123" } } }

          run_test!
        end
      end

      context "when searching by national_insurance_number" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantNINO: "HB133542A" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          let(:filter) { { filter: { national_insurance_number: "HB133542A" } } }

          run_test!
        end
      end

      context "when searching by name and date of birth" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantName: "George Walsh", defendantDOB: "1980-01-01" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          let(:filter) { { filter: { name: "George Walsh", date_of_birth: "1980-01-01" } } }

          run_test!
        end
      end

      context "when searching by name and date of next hearing" do
        response(200, "Success") do
          before do
            stub_prosecution_case_search(
              query: { defendantName: "George Walsh", dateOfNextHearing: "2020-02-17" },
              body: file_fixture("prosecution_case_search_result.json").read,
            )
          end

          let(:filter) { { filter: { name: "George Walsh", date_of_next_hearing: "2020-02-17" } } }

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }
          let(:filter) { { filter: { name: "George Walsh", date_of_next_hearing: "2020-02-17" } } }

          run_test!
        end
      end
    end
  end

  path "/api/internal/v2/prosecution_cases/{prosecution_case_reference}/court_applications" do
    get("fetch court applications related to prosecution case") do
      description "retrieves full details of court applications related to a prosecution case"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      produces "application/vnd.api+json"

      parameter name: :prosecution_case_reference, in: :path, required: true,
                schema: {
                  "$ref": "prosecution_case_identifier.json#/properties/case_urn",
                },
                description: "The unique reference number (URN) of the case"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      let(:Authorization) { "Bearer #{token.token}" }
      let(:application_ids) { %w[62158b87-56fc-43cc-bbdc-d957d372420f] }
      let(:prosecution_case_reference) { "CPS186472" }

      before do
        stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/prosecutionCases")
            .with(query: { prosecutionCaseReference: prosecution_case_reference })
            .to_return(
              status: 200,
              headers: { content_type: "application/json" },
              body: file_fixture("prosecution_case_search_result_with_application_summary.json").read,
            )
      end

      context "when successful" do
        before do
          application_ids.each do |application_id|
            stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/applications/#{application_id}")
              .to_return(
                headers: { content_type: "application/json" },
                body: file_fixture("court_application_summary.json").read,
              )
          end
        end

        response(200, "Success") do
          schema "$ref" => "prosecution_case_court_applications.json#"
          run_test!
        end
      end

      context "when upstream error" do
        before do
          application_ids.each do |application_id|
            stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/applications/#{application_id}")
              .to_return(
                headers: { content_type: "application/json" },
                status: 500,
              )
          end
        end

        response(424, "Failed dependency") do
          run_test!
        end
      end

      context "when unauthorized" do
        response(401, "Unauthorized") do
          let(:Authorization) { nil }

          run_test!
        end
      end
    end
  end
end
