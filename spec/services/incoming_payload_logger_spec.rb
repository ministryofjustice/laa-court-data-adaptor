RSpec.describe IncomingPayloadLogger do
  subject(:log_payload) { described_class.call(body, request_id, payload_type, identifier) }

  let(:body) { { "key" => "value" } }
  let(:request_id) { SecureRandom.uuid }
  let(:payload_type) { "hearing_resulted" }
  let(:identifier) { "12345" }

  it "creates an IncomingPayload record" do
    expect {
      log_payload
    }.to change(IncomingPayload, :count).by(1)
  end
end
