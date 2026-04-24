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

      parameter name: :sort_by, in: :query, required: false, type: :string,
                schema: {
                  type: :string,
                  enum: %w[
                    case_urn
                    xhibit_case_number
                    case_type
                    court_name
                    defendant_name
                    created_at
                    maat_id
                    linked_by
                    status
                  ],
                },
                description: "Sort field"

      parameter name: :sort_direction, in: :query, required: false, type: :string,
                schema: {
                  type: :string,
                  enum: %w[asc desc],
                },
                description: "Sort direction"

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

  describe "sorting behavior" do
    let(:headers) { { "Authorization" => "Bearer #{token.token}" } }

    sorting_cases = {
      "case_urn" => { column: :case_urn, values: %w[URN-B URN-A URN-C] },
      "xhibit_case_number" => { column: :xhibit_case_number, values: %w[T-300 T-100 T-200] },
      "case_type" => { column: :case_type, values: %w[T A S] },
      "court_name" => { column: :court_name, values: ["York Crown Court", "Bristol Crown Court", "Woolwich Crown Court"] },
      "created_at" => {
        column: :created_at,
        values: [
          Time.zone.parse("2024-01-03 09:00:00"),
          Time.zone.parse("2024-01-01 09:00:00"),
          Time.zone.parse("2024-01-02 09:00:00"),
        ],
      },
      "maat_id" => { column: :maat_id, values: %w[300003 100001 200002] },
      "linked_by" => { column: :linked_by, values: %w[user-z user-a user-m] },
      "status" => { column: :status, values: %w[pending action_required auto_linked] },
    }.freeze

    sorting_cases.each do |sort_by, scenario|
      it "sorts #{sort_by} ascending" do
        records = scenario[:values].each_with_index.map do |value, index|
          create_migrated_case(
            status: "pending",
            suffix: index,
            case_urn: "CASE-#{sort_by}-#{index}",
            xhibit_case_number: "XHIBIT-#{sort_by}-#{index}",
            scenario[:column] => value,
          )
        end

        request_sorted(sort_by:, sort_direction: "asc", headers:)

        expect(response).to have_http_status(:ok)
        expect(result_ids).to eq(expected_order(records, scenario[:column], "asc"))
      end

      it "sorts #{sort_by} descending" do
        records = scenario[:values].each_with_index.map do |value, index|
          create_migrated_case(
            status: "pending",
            suffix: index,
            case_urn: "CASE-DESC-#{sort_by}-#{index}",
            xhibit_case_number: "XHIBIT-DESC-#{sort_by}-#{index}",
            scenario[:column] => value,
          )
        end

        request_sorted(sort_by:, sort_direction: "desc", headers:)

        expect(response).to have_http_status(:ok)
        expect(result_ids).to eq(expected_order(records, scenario[:column], "desc"))
      end
    end

    it "sorts defendant_name ascending by first name then last name" do
      create_migrated_case(status: "pending", suffix: 1, defendant_first_name: "Alex", defendant_last_name: "Zulu")
      create_migrated_case(status: "pending", suffix: 2, defendant_first_name: "Alex", defendant_last_name: "Alpha")
      create_migrated_case(status: "pending", suffix: 3, defendant_first_name: "Ben", defendant_last_name: "Bravo")

      request_sorted(sort_by: "defendant_name", sort_direction: "asc", headers:)

      expect(response).to have_http_status(:ok)
      expect(result_name_pairs).to eq(
        [
          %w[Alex Alpha],
          %w[Alex Zulu],
          %w[Ben Bravo],
        ],
      )
    end

    it "sorts defendant_name descending by first name then last name" do
      create_migrated_case(status: "pending", suffix: 4, defendant_first_name: "Alex", defendant_last_name: "Zulu")
      create_migrated_case(status: "pending", suffix: 5, defendant_first_name: "Alex", defendant_last_name: "Alpha")
      create_migrated_case(status: "pending", suffix: 6, defendant_first_name: "Ben", defendant_last_name: "Bravo")

      request_sorted(sort_by: "defendant_name", sort_direction: "desc", headers:)

      expect(response).to have_http_status(:ok)
      expect(result_name_pairs).to eq(
        [
          %w[Ben Bravo],
          %w[Alex Zulu],
          %w[Alex Alpha],
        ],
      )
    end

    it "falls back to created_at ascending when sort_by is invalid" do
      early = create_migrated_case(status: "pending", suffix: 10, created_at: Time.zone.parse("2024-01-01 09:00:00"))
      middle = create_migrated_case(status: "pending", suffix: 11, created_at: Time.zone.parse("2024-01-02 09:00:00"))
      late = create_migrated_case(status: "pending", suffix: 12, created_at: Time.zone.parse("2024-01-03 09:00:00"))

      request_sorted(sort_by: "unknown_field", sort_direction: "desc", headers:)

      expect(response).to have_http_status(:ok)
      expect(result_ids).to eq([early.id, middle.id, late.id])
    end

    it "falls back to created_at ascending when sort_direction is invalid" do
      early = create_migrated_case(status: "pending", suffix: 13, created_at: Time.zone.parse("2024-01-01 09:00:00"))
      middle = create_migrated_case(status: "pending", suffix: 14, created_at: Time.zone.parse("2024-01-02 09:00:00"))
      late = create_migrated_case(status: "pending", suffix: 15, created_at: Time.zone.parse("2024-01-03 09:00:00"))

      request_sorted(sort_by: "case_urn", sort_direction: "invalid", headers:)

      expect(response).to have_http_status(:ok)
      expect(result_ids).to eq([early.id, middle.id, late.id])
    end

    it "uses db default null ordering for maat_id" do
      create_migrated_case(status: "pending", suffix: 16, maat_id: nil)
      create_migrated_case(status: "pending", suffix: 17, maat_id: "200002")
      create_migrated_case(status: "pending", suffix: 18, maat_id: "100001")

      request_sorted(sort_by: "maat_id", sort_direction: "asc", headers:)
      expect(result_field_values("maat_id")).to eq(["100001", "200002", nil])

      request_sorted(sort_by: "maat_id", sort_direction: "desc", headers:)
      expect(result_field_values("maat_id")).to eq([nil, "200002", "100001"])
    end

    it "uses db default null ordering for linked_by" do
      create_migrated_case(status: "pending", suffix: 19, linked_by: nil)
      create_migrated_case(status: "pending", suffix: 20, linked_by: "user-z")
      create_migrated_case(status: "pending", suffix: 21, linked_by: "user-a")

      request_sorted(sort_by: "linked_by", sort_direction: "asc", headers:)
      expect(result_field_values("linked_by")).to eq(["user-a", "user-z", nil])

      request_sorted(sort_by: "linked_by", sort_direction: "desc", headers:)
      expect(result_field_values("linked_by")).to eq([nil, "user-z", "user-a"])
    end

    it "applies sorting before pagination" do
      %w[D A C B].each_with_index do |case_urn, index|
        create_migrated_case(status: "pending", suffix: 40 + index, case_urn:)
      end
      create_migrated_case(status: "auto_linked", suffix: 50, case_urn: "AA")

      request_sorted(
        sort_by: "case_urn",
        sort_direction: "asc",
        headers:,
        params: {
          status: "pending",
          page: 2,
          per_page: 2,
        },
      )

      body = parsed_body

      expect(response).to have_http_status(:ok)
      expect(body["total_results"]).to eq(4)
      expect(body["results"].map { |record| record["case_urn"] }).to eq(%w[C D])
    end
  end

  def expected_order(records, column, direction)
    ordered = records.sort_by { |record| [record.public_send(column), record.id] }
    ordered = ordered.reverse if direction == "desc"
    ordered.map(&:id)
  end

  def parsed_body
    JSON.parse(response.body)
  end

  def result_ids
    parsed_body.fetch("results").map { |record| record.fetch("id") }
  end

  def result_name_pairs
    parsed_body.fetch("results").map { |record| [record["defendant_first_name"], record["defendant_last_name"]] }
  end

  def result_field_values(field)
    parsed_body.fetch("results").map { |record| record[field] }
  end

  def request_sorted(sort_by:, sort_direction:, headers:, params: {})
    get "/api/internal/v2/link_migrated_cases", params: params.merge(sort_by:, sort_direction:), headers:
  end

  def create_migrated_case(status:, suffix:, **overrides)
    XhibitMigratedCase.create!(
      {
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
      }.merge(overrides),
    )
  end
end
