# frozen_string_literal: true

RSpec.describe UnlinkLaaReferenceJob, type: :job do
  include ActiveJob::TestHelper

  let(:contract) do
    {
      user_name: 'ABC',
      unlink_reason_code: '1',
      unlink_reason_text: 'Wrong defendant',
      defendant_id: 'LONG-UUID'
    }
  end

  describe '#perform_later' do
    subject(:job) do
      described_class.perform_later(contract: contract, request_id: 'XYZ')
    end

    it 'queues a call to update the laa reference' do
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a LaaReferenceUnlinker and calls it' do
      expect(LaaReferenceUnlinker).to receive(:call).once.with(contract)
      perform_enqueued_jobs { job }
    end

    it 'sets the request_id on the Current singleton' do
      allow(LaaReferenceUnlinker).to receive(:call)
      expect(Current).to receive(:set).with(request_id: 'XYZ')
      perform_enqueued_jobs { job }
    end
  end
end
