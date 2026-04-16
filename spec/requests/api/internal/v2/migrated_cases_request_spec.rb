# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/link_migrated_cases", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:Authorization) { "Bearer #{token.token}" }

  path "/api/internal/v2/link_migrated_cases" do
    get("list migrated cases") do
      description "List XHIBIT migrated cases with optional status filter and pagination"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]
      consumes "application/json"
      produces "application/json"

      parameter name: :status, in: :query, required: false, type: :string,
                schema: {
                  type: :string,
                  enum: %w[pending auto_linked manually_linked action_required],
                },
                description: "Filter records by status"

      parameter name: :page, in: :query, required: false, type: :integer,
                description: "Page number (default: 1)"

      parameter name: :per_page, in: :query, required: false, type: :integer,
                description: "Records per page (default: 10)"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      response(200, "Success with default pagination") do
        before do
          12.times { |index| create_migrated_case(status: "pending", suffix: index) }
        end

        run_test! do |http_response|
          body = JSON.parse(http_response.body)

          expect(body["total_results"]).to eq(12)
          expect(body["page"]).to eq(1)
          expect(body["per_page"]).to eq(10)
          expect(body["results"].size).to eq(10)
        end
      end

      response(200, "Success filtered by status") do
        let(:status) { "pending" }

        before do
          3.times { |index| create_migrated_case(status: "pending", suffix: index) }
          create_migrated_case(status: "auto_linked", suffix: 3)
          create_migrated_case(status: "action_required", suffix: 4)
        end

        run_test! do |http_response|
          body = JSON.parse(http_response.body)

          expect(body["total_results"]).to eq(3)
          expect(body["results"].size).to eq(3)
          expect(body["results"].map { |record| record["status"] }.uniq).to eq(%w[pending])
        end
      end

      response(200, "Success with custom page and per_page") do
        let(:page) { 2 }
        let(:per_page) { 7 }

        before do
          25.times { |index| create_migrated_case(status: "manually_linked", suffix: index) }
        end

        run_test! do |http_response|
          body = JSON.parse(http_response.body)

          expect(body["total_results"]).to eq(25)
          expect(body["page"]).to eq(2)
          expect(body["per_page"]).to eq(7)
          expect(body["results"].size).to eq(7)
        end
      end

      response(200, "When per_page is above 100, it defaults to 10") do
        let(:per_page) { 101 }

        before do
          120.times { |index| create_migrated_case(status: "pending", suffix: index) }
        end

        run_test! do |http_response|
          body = JSON.parse(http_response.body)

          expect(body["total_results"]).to eq(120)
          expect(body["per_page"]).to eq(10)
          expect(body["results"].size).to eq(10)
        end
      end

      response(200, "When per_page is below 1, it defaults to 10") do
        let(:per_page) { 0 }

        before do
          12.times { |index| create_migrated_case(status: "pending", suffix: index) }
        end

        run_test! do |http_response|
          body = JSON.parse(http_response.body)

          expect(body["total_results"]).to eq(12)
          expect(body["per_page"]).to eq(10)
          expect(body["results"].size).to eq(10)
        end
      end

      response(401, "Unauthorized") do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  def create_migrated_case(status:, suffix:)
    XhibitMigratedCase.create!(
      case_urn: "20GD0217#{suffix}",
      xhibit_case_number: "T20254#{suffix}",
      court_name: "Derby Justice Centre",
      ou_code: "B30PI00",
      case_type: "T",
      case_sub_type: "Either way offence",
      mode_of_trial: "Either way",
      defendant_id: "defendant-#{suffix}",
      defendant_first_name: "John",
      defendant_middle_name: nil,
      defendant_last_name: "Doe#{suffix}",
      defendant_date_of_birth: Date.new(1987, 5, 21),
      defendant_arrest_summons_number: "ASN#{suffix}",
      committal_date: nil,
      sent_date: Date.new(2019, 10, 25),
      status:,
    )
  end
end
