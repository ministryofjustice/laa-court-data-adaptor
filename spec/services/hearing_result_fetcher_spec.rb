# frozen_string_literal: true

RSpec.describe HearingResultFetcher do
  subject(:fetch_hearing_result) do
    described_class.call(
      hearing_id,
      sitting_day,
    )
  end

  let(:hearing_resulted_data) { JSON.parse(file_fixture("hearing_resulted.json").read) }
  let(:hearing_id) { hearing_resulted_data["hearing"]["id"] }
  let(:sitting_day) { "2022-12-05" }

  let(:response) do
    instance_double(
      Faraday::Response,
      body: hearing_resulted_data,
      status: 200,
      success?: true,
    )
  end

  before do
    Current.request_id = "XYZ"
  end

  it "calls HearingsCreator" do
    allow(CommonPlatform::Api::HearingFetcher)
      .to receive(:call)
      .and_return(response)

    expect(HearingsCreator)
      .to receive(:call)
      .once
      .with(
        hearing_resulted_data: hearing_resulted_data,
        queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
      )

    fetch_hearing_result
  end

  context "when hearing resulted data is not yet available on Common Platform" do
    let(:response) do
      instance_double(
        Faraday::Response,
        body: {},
        status: 200,
        success?: true,
      )
    end

    it "raises an error" do
      allow(CommonPlatform::Api::HearingFetcher)
        .to receive(:call)
        .and_return(response)

      expected_msg = "[XYZ] - Past result for hearing ID b935a64a-6d03-4da4-bba6-4d32cc2e7fb4 is not available."

      expect { fetch_hearing_result }.to raise_error(StandardError, expected_msg)
    end
  end

  context "when Common Platform is unresponsive" do
    let(:response) do
      instance_double(
        Faraday::Response,
        status: 500,
        success?: false,
      )
    end

    it "raises an error" do
      allow(CommonPlatform::Api::HearingFetcher)
        .to receive(:call)
        .and_return(response)

      expected_msg = "[XYZ] - Unable to fetch past result of hearing ID b935a64a-6d03-4da4-bba6-4d32cc2e7fb4: Common Platform responded with status code 500."

      expect { fetch_hearing_result }.to raise_error(StandardError, expected_msg)
    end
  end
end
