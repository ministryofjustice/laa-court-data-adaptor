# frozen_string_literal: true

RSpec.describe Sqs::MessagePublisher do
  let(:client_double) { instance_double("Aws::SQS::Client") }

  subject { described_class.call(message: { blah: "blah" }, sqs_client: client_double) }

  it "does not publish a message" do
    expect(client_double).not_to receive(:send_message)
    subject
  end

  context "when the queue url is provided" do
    subject { described_class.call(message: { blah: "blah" }, queue_url: "/fancy-sqs-url", sqs_client: client_double) }

    before do
      allow(Current).to receive(:request_id).and_return("XYZ")
    end

    let(:json_message_body) do
      '{"blah":"blah","metadata":{"laaTransactionId":"XYZ"}}'
    end

    it "publishes a message to the sqs queue as json" do
      expect(client_double).to receive(:send_message).with(queue_url: "/fancy-sqs-url", message_body: json_message_body)
      subject
    end
  end
end
