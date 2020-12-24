# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v1/prosecution_cases", type: :request, swagger_doc: "v1/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:schema) { File.read("swagger/v1/schema.json") }
  let(:include) {}

  before do
    allow(Api::GetHearingResults).to receive(:call)
  end

  path "/api/internal/v1/prosecution_cases" do
    get("search prosecution_cases") do
      description 'Search prosecution cases. Valid search combinations are: <br/><br/>
                    1) prosecution_case_reference <br/>
                    2) arrest_summons_number <br/>
                    3) national_insurance_number <br/>
                    4) name and date_of_birth <br/>
                    5) name and date_of_next_hearing'
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      context "search by prosecution_case_reference" do
        response(200, "Success") do
          around do |example|
            VCR.use_cassette("search_prosecution_case/by_prosecution_case_reference_success") do
              example.run
            end
          end

          produces 'application/vnd.api+json'

          parameter name: "filter[prosecution_case_reference]", in: :query, required: false, type: :string,
                    schema: {
                      '$ref': "prosecution_case.json#/definitions/prosecution_case_reference",
                    },
                    description: "Searches prosecution cases by prosecution case reference"

          parameter name: "include", in: :query, required: false, type: :string,
                    schema: {},
                    description: 'Return defendant and offence data through a has_many relationship </br>
                                  eg include=defendants,defendants.offences,defendants.defence_organisation'

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          schema '$ref' => "prosecution_case.json#/definitions/resource_collection"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[prosecution_case_reference]') { "19GD1001816" }
          let(:include) { "defendants,defendants.offences,defendants.defence_organisation" }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context "search by arrest_summons_number" do
        response(200, "Success") do
          around do |example|
            VCR.use_cassette("search_prosecution_case/by_arrest_summons_number_success") do
              example.run
            end
          end

          parameter name: "filter[arrest_summons_number]", in: :query, required: false, type: :string,
                    schema: {
                      '$ref': "prosecution_case.json#/definitions/arrest_summons_number",
                    },
                    description: "Searches prosecution cases by arrest summons number"

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[arrest_summons_number]') { "arrest123" }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context "search by national_insurance_number" do
        response(200, "Success") do
          around do |example|
            VCR.use_cassette("search_prosecution_case/by_national_insurance_number_success") do
              example.run
            end
          end

          parameter name: "filter[national_insurance_number]", in: :query, required: false, type: :string,
                    schema: {
                      '$ref': "defendant.json#/definitions/nino",
                    },
                    description: "Searches prosecution cases by national_insurance_number"

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[national_insurance_number]') { "HB133542A" }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context "search by name and date of birth" do
        response(200, "Success") do
          around do |example|
            VCR.use_cassette("search_prosecution_case/by_name_and_date_of_birth_success") do
              example.run
            end
          end

          parameter name: "filter[name]", in: :query, required: false, type: :string,
                    schema: {
                      '$ref': "defendant.json#/definitions/name",
                    },
                    description: "Searches prosecution cases by name"

          parameter name: "filter[date_of_birth]", in: :query, required: false, type: :string,
                    schema: {
                      '$ref': "defendant.json#/definitions/date_of_birth",
                    },
                    description: "Searches prosecution cases by date_of_birth"

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[name]') { "George Walsh" }
          let(:'filter[date_of_birth]') { "1980-01-01" }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context "search by name and date of next hearing" do
        response(200, "Success") do
          around do |example|
            VCR.use_cassette("search_prosecution_case/by_name_and_date_of_next_hearing_success") do
              example.run
            end
          end

          parameter name: "filter[name]", in: :query, required: false, type: :string,
                    schema: {
                      '$ref': "defendant.json#/definitions/name",
                    },
                    description: "Searches prosecution cases by name"

          parameter name: "filter[date_of_next_hearing]", in: :query, required: false, type: :string,
                    schema: {
                      '$ref': "prosecution_case.json#/definitions/date_of_next_hearing",
                    },
                    description: "Searches prosecution cases by date_of_next_hearing"

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[name]') { "George Walsh" }
          let(:'filter[date_of_next_hearing]') { "2020-02-17" }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context "unauthorized request" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          run_test!
        end
      end
    end
  end
end
