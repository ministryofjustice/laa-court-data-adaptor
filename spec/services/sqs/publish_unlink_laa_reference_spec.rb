# frozen_string_literal: true

RSpec.describe Sqs::PublishUnlinkLaaReference do
  let(:maat_reference) { 123_456 }
  let(:user_name) { 'test@example.com' }
  let(:unlink_reason_code) { 1 }
  let(:unlink_reason_text) { 'linked to incorrect case' }

  let(:sqs_payload) do
    {
      maatId: maat_reference,
      userId: user_name,
      unlinkReasonId: unlink_reason_code,
      unlinkReasonText: unlink_reason_text
    }
  end

  subject { described_class.call(maat_reference: maat_reference, user_name: user_name, unlink_reason_code: unlink_reason_code, unlink_reason_text: unlink_reason_text) }

  before do
    allow(Rails.configuration.x.aws).to receive(:sqs_url_unlink).and_return('/unlink-sqs-url')
  end

  it 'triggers a publish call with the sqs payload' do
    expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: '/unlink-sqs-url')
    subject
  end
end
