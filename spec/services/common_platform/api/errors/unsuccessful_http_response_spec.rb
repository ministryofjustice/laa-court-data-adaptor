# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::Errors::UnsuccessfulHttpResponse do
  it "includes service, status and body in the message" do
    error = described_class.new(
      service: "MyService",
      status: 401,
      body: { "statusCode" => 401, "message" => "Access denied due to invalid subscription key. Make sure to provide a valid key for an active subscription." },
    )
    expect(error.message).to eq(
      'MyService failed with status 401: {"statusCode" => 401, "message" => "Access denied due to invalid subscription key. Make sure to provide a valid key for an active subscription."}',
    )
  end
end
