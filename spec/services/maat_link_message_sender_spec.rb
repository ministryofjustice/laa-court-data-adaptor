# frozen_string_literal: true

RSpec.describe MaatLinkMessageSender do
  subject(:call_service) do
    described_class.call(
      defendant_id:,
      user_name:,
      maat_reference:,
      court_centre_id:,
      oucode:,
    )
  end

  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:user_name) { "peter.rabbit" }
  let(:maat_reference) { "12345678" }
  let(:court_centre_id) { "f8254db1-1683-483e-afb3-b87fde5a0a26" }
  let(:oucode) { "B01JQ" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:offence_id) { "cacbd4d4-9102-4687-98b4-d529be3d5710" }

  before do
    create(:prosecution_case,
           id: prosecution_case_id,
           body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0])

    create(:prosecution_case_defendant_offence,
           prosecution_case_id:,
           defendant_id:,
           offence_id:)

    create(:court_centre_organisation_unit_code, court_centre_id:, code: "B01LY00")

    allow(Sqs::MessagePublisher).to receive(:call)
  end

  describe "#call" do
    it "sends the message to SQS with correct parameters" do
      Current.set(request_id: "test-request-id") do
        call_service
      end

      expect(Sqs::MessagePublisher).to have_received(:call) do |arg|
        expect(arg[:message]).to include(
          maatId: maat_reference,
          caseUrn: "20GD0217100",
          asn: "ARREST123",
          cjsAreaCode: "1",
          cjsLocation: oucode,
          createdUser: user_name,
        )
        expect(arg[:queue_url]).to eq(Rails.configuration.x.aws.sqs_url_link)
        expect(arg[:log_info]).to eq({ maat_reference: })
      end
    end

    describe "validation errors" do
      it "raises `ArgumentError` when `defendant_id` is missing" do
        expect {
          described_class.call(
            defendant_id: nil,
            user_name:,
            maat_reference:,
            court_centre_id:,
            oucode:,
          )
        }.to raise_error(ArgumentError, "defendant_id is required")
      end

      it "raises `ArgumentError` when `user_name` is missing" do
        expect {
          described_class.call(
            defendant_id:,
            user_name: nil,
            maat_reference:,
            court_centre_id:,
            oucode:,
          )
        }.to raise_error(ArgumentError, "user_name is required")
      end

      it "raises `ArgumentError` when `maat_reference` is missing" do
        expect {
          described_class.call(
            defendant_id:,
            user_name:,
            maat_reference: nil,
            court_centre_id:,
            oucode:,
          )
        }.to raise_error(ArgumentError, "maat_reference is required")
      end

      it "raises `ArgumentError` when `court_centre_id` is missing" do
        expect {
          described_class.call(
            defendant_id:,
            user_name:,
            maat_reference:,
            court_centre_id: nil,
            oucode:,
          )
        }.to raise_error(ArgumentError, "court_centre_id is required")
      end

      it "raises `ArgumentError` when `oucode` is missing" do
        expect {
          described_class.call(
            defendant_id:,
            user_name:,
            maat_reference:,
            court_centre_id:,
            oucode: nil,
          )
        }.to raise_error(ArgumentError, "oucode is required")
      end

      it "raises `ArgumentError` when `defendant` is not found" do
        expect {
          described_class.call(
            defendant_id: "wrong-id",
            user_name:,
            maat_reference:,
            court_centre_id:,
            oucode:,
          )
        }.to raise_error(ArgumentError, "Defendant not found for ID: wrong-id")
      end
    end
  end
end
