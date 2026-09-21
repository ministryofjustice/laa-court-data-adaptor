require "pact/rspec"

RSpec.describe "Maat Reference Validator contract", :pact do
  include_context "with laa-maat-court-data-api consumer pact"

  describe MaatApi::MaatReferenceValidator do
    describe "#error_code" do
      subject { described_class.call(maat_reference: maat_reference, connection: connection).error_code }

      let(:maat_reference) { "1234567" }
      let(:connection) { MaatApi::Connection.new(host: mock_server.url).call }
      let(:mock_server) { @mock_server }

      let(:headers) do
        {
          "Authorization" => match_any_string,
          "Content-Type" => "application/json",
        }
      end

      let(:interaction) do
        new_interaction
          .given(scenario_state)
          .upon_receiving("a request to validate a MAAT reference")
          .with_request(
            method: :post,
            path: "/link/validate",
            headers: headers,
            body: {
              "caseUrn" => match_any_string("XYZ"),
              "maatId" => match_regex(/\A[0-9]{7}\z/, maat_reference),
            },
          )
          .will_respond_with(
            status: status,
            body: response_body,
          )
      end

      before { stub_maat_api_token }

      around do |example|
        interaction.execute do |mock_server|
          @mock_server = mock_server
          example.run
        end
      end

      context "when MAAT reference is valid and not linked" do
        let(:scenario_state) { "a valid MAAT reference" }
        let(:status) { 200 }
        let(:response_body) { "" }

        it { is_expected.to be_nil }
      end

      context "when MAAT reference is already linked" do
        let(:scenario_state) { "a MAAT reference that is already linked" }
        let(:status) { 400 }
        let(:response_body) do
          {
            "code" => "BAD_REQUEST",
            "message" => "#{maat_reference} is already linked to a case.",
          }
        end

        it { is_expected.to eq(:already_linked) }
      end

      context "when MAAT reference has no common platform data" do
        let(:scenario_state) { "a MAAT reference that has no common platform data" }
        let(:status) { 400 }
        let(:response_body) do
          {
            "code" => "BAD_REQUEST",
            "message" => "#{maat_reference} has no common platform data created against Maat application.",
          }
        end

        it { is_expected.to eq(:no_common_platform_data) }
      end

      context "when MAAT reference is invalid" do
        let(:scenario_state) { "a MAAT reference that is invalid" }
        let(:status) { 400 }
        let(:response_body) do
          {
            "code" => "BAD_REQUEST",
            "message" => "MAAT/REP ID [#{maat_reference}] is invalid",
          }
        end

        it { is_expected.to eq(:invalid) }
      end
    end
  end
end
