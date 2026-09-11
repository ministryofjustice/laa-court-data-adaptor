# frozen_string_literal: true

RSpec.describe RequestLibraUnlink, type: :service do
  subject(:request_unlink) { described_class.call(maat_response, xhibit_case) }

  let(:maat_response) { instance_double(MaatApi::SearchResponse, maat_id: 6_672_961) }

  let(:xhibit_case) do
    create(:xhibit_migrated_case,
           defendant_id: "b7c8e2f0-0000-4000-8000-000000000001",
           defendant_first_name: "Alice",
           defendant_last_name: "Smith")
  end

  before { allow(Sqs::MessagePublisher).to receive(:call) }

  it "publishes an unlink request to the MAAT unlink queue" do
    request_unlink

    expect(Sqs::MessagePublisher).to have_received(:call).with(
      message: {
        defendantId: "b7c8e2f0-0000-4000-8000-000000000001",
        maatId: "6672961",
        userId: User::SYSTEM_USERNAME,
        reasonId: LaaReference::OTHER_REASON_CODE,
        otherReasonText: "XHIBIT migration: unlinking from LIBRA case",
      },
      queue_url: Rails.configuration.x.aws.sqs_url_unlink,
      log_info: { maat_reference: "6672961" },
    )
  end
end
