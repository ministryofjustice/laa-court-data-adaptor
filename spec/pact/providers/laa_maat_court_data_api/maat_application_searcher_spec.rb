require "pact/rspec"

RSpec.describe "Maat Application Searcher contract", :pact do
  include_context "with laa-maat-court-data-api consumer pact"

  describe MaatApi::MaatApplicationSearcher do
    describe "#status" do
      subject { described_class.call(**args.merge(connection: connection)).status }

      let(:args) do
        {
          first_name: "First name",
          last_name: "Last name",
          date_of_birth: "2000-01-01",
          national_insurance_number: "AB123456C",
          arrest_summons_number: "1234567",
          committal_date: "2020-01-01",
          case_type: "Case type",
        }
      end

      let(:request_headers) do
        {
          "Authorization" => match_any_string,
          "Content-Type" => "application/json",
        }
      end

      let(:response_headers) do
        {
          "Content-Type" => "application/json",
        }
      end

      let(:maat_search_url) { MaatApi::MaatApplicationSearcher::URL }

      let(:request_body) do
        {
          firstName: match_any_string(args[:first_name]),
          lastName: match_any_string(args[:last_name]),
          dob: match_any_string(args[:date_of_birth]),
          niNumber: match_any_string(args[:national_insurance_number]),
          asn: match_any_string(args[:arrest_summons_number]),
          committalDate: match_any_string(args[:committal_date]),
          caseType: match_any_string(args[:case_type]),
        }
      end

      let(:interaction) do
        new_interaction
          .given(scenario_state)
          .upon_receiving("a request to search for a MAAT application")
          .with_request(
            method: :post,
            headers: request_headers,
            path: "/#{maat_search_url}",
            body: request_body,
          )
          .will_respond_with(
            status: status,
            headers: response_headers,
            body: response_body,
          )
      end

      context "when there is a matching MAAT application with linking data" do
        let(:scenario_state) { "matching MAAT application with linking data" }
        let(:status) { 200 }
        let(:response_body) do
          match_each([
            {
              "maatId": match_any_integer,
              "linkingDetail": {
                "libraId": match_any_string,
                "caseId": match_any_integer,
                "caseUrn": match_any_string,
                "cjsAreaCode": match_any_string,
                "cjsLocation": match_any_string,
              },
              "linked": true,
              "isLinked": true,
            },
          ])
        end

        it { is_expected.to eq(200) }
      end

      context "when there is a matching MAAT application with no linking data" do
        let(:scenario_state) { "matching MAAT application with no linking data" }
        let(:status) { 200 }
        let(:response_body) do
          match_each([
            {
              "maatId": match_any_integer,
              "linkingDetail": nil,
              "isLinked": false,
              "linked": false,
            },
          ])
        end

        it { is_expected.to eq(200) }
      end

      context "when there is no matching MAAT application" do
        let(:scenario_state) { "no matching MAAT applications" }
        let(:status) { 404 }
        let(:response_body) do
          {
            "code": "NOT_FOUND",
            "message": "Representation order not found",
          }
        end

        it { is_expected.to eq(404) }
      end

      context "when firstName is not specified" do
        let(:scenario_state) { "firstName is not specified" }
        let(:status) { 400 }
        let(:response_body) do
          {
            "title": "Bad Request",
            "status": 400,
            "detail": "Invalid request content.",
            "instance": "/api/internal/v1/assessment/rep-orders/search-maat-application",
          }
        end

        let(:args) do
          {
            last_name: "Last name",
            date_of_birth: "2000-01-01",
            national_insurance_number: "AB123456C",
            arrest_summons_number: "1234567",
            committal_date: "2020-01-01",
            case_type: "Case type",
          }
        end

        let(:request_body) do
          {
            lastName: match_any_string(args[:last_name]),
            dob: match_any_string(args[:date_of_birth]),
            niNumber: match_any_string(args[:national_insurance_number]),
            asn: match_any_string(args[:arrest_summons_number]),
            committalDate: match_any_string(args[:committal_date]),
            caseType: match_any_string(args[:case_type]),
          }
        end

        let(:response_headers) do
          {
            "Content-Type" => "application/problem+json",
          }
        end

        it { is_expected.to eq(400) }
      end
    end
  end
end
