# frozen_string_literal: true

RSpec.describe Sqs::MessagePublisher do
  subject(:publish) { described_class.call(message:, sqs_client: client_double) }

  let(:client_double) { instance_double(Aws::SQS::Client) }
  let(:message) { { blah: "blah" } }

  it "does not publish a message" do
    expect(client_double).not_to receive(:send_message)
    publish
  end

  context "when the queue url is provided" do
    subject(:publish) { described_class.call(message:, queue_url: "/fancy-sqs-url", sqs_client: client_double) }

    before do
      allow(Current).to receive(:request_id).and_return("XYZ")
    end

    let(:json_message_body) do
      '{"blah":"blah","metadata":{"laaTransactionId":"XYZ"}}'
    end

    it "publishes a message to the sqs queue as json" do
      expect(client_double).to receive(:send_message).with(queue_url: "/fancy-sqs-url", message_body: json_message_body)
      publish
    end

    context "when message contains invalid characters" do
      let(:message) { { blah: "â’r \uFFFFcloud\uFFFF 🐱‍💻" } }

      it "publishes a sanitized version of the message" do
        expect(client_double).to receive(:send_message).with(
          queue_url: "/fancy-sqs-url",
          message_body: '{"blah":"â’r cloud 🐱‍💻","metadata":{"laaTransactionId":"XYZ"}}',
        )
        publish
      end
    end
  end
end
