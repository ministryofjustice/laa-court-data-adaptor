# frozen_string_literal: true

RSpec.describe Sqs::PublishLaaReference do
  subject(:publish) { described_class.call(prosecution_case_id: prosecution_case_id, defendant_id: defendant_id, user_name: "bossMan", maat_reference: maat_reference) }

  include ActiveSupport::Testing::TimeHelpers
  let(:prosecution_case_id) { "5edd67eb-9d8c-44f2-a57e-c8d026defaa4" }
  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:maat_reference) { 123_456 }

  let(:sqs_payload) do
    {
      maatId: maat_reference,
      caseUrn: "20GD0217100",
      asn: "ARREST123",
      cjsAreaCode: cjs_area_code,
      cjsLocation: cjs_location,
      createdUser: "bossMan",
      docLanguage: "EN",
      isActive: false,
      defendant: {
        defendantId: "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3",
        forename: "George",
        surname: "Walsh",
        dateOfBirth: "1980-01-01",
        nino: "HB133542A",
        offences: [
          {
            offenceId: "3f153786-f3cf-4311-bc0c-2d6f48af68a1",
            offenceCode: "PT00011",
            asnSeq: 1,
            offenceClassification: "Summary",
            offenceDate: "2020-02-01",
            offenceShortTitle: "Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable",
            offenceWording: "Test",
          },
        ],
      },
      sessions: [
        { courtLocation: "B01BH", dateOfHearing: "2020-02-17" },
        { courtLocation: "C05LV", dateOfHearing: "2020-08-04" },
        { courtLocation: "B01LY", dateOfHearing: "2020-09-05" },
        { courtLocation: "C05LV", dateOfHearing: nil },
      ],
    }
  end

  let(:queue_url) { Rails.configuration.x.aws.sqs_url_link }

  let(:cjs_area_code)  { "1" }
  let(:cjs_location)   { "B01LY" }

  before do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0],
    )
  end

  it "returns the CJS area code and location from the most recent past hearing" do
    travel_to Time.zone.local(2020, 9, 6) do
      expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url).and_call_original
      publish
    end
  end

  context "when all hearings are in the future" do
    let(:cjs_area_code)  { "1" }
    let(:cjs_location)   { "B01BH" }

    it "returns the CJS area code and location from the next upcoming hearing " do
      travel_to Time.zone.local(2020, 2, 1) do
        expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url).and_call_original
        publish
      end
    end
  end

  context "when one hearing is in the future" do
    let(:cjs_area_code)  { "5" }
    let(:cjs_location)   { "C05LV" }

    it "returns the CJS area code and location from the most recent past hearing " do
      travel_to Time.zone.local(2020, 8, 10) do
        expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url).and_call_original
        publish
      end
    end
  end
end
