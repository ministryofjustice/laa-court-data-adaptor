# frozen_string_literal: true

RSpec.describe UnlinkLaaReferenceJob, type: :job do
  include ActiveJob::TestHelper
  describe '#perform_later' do
    subject(:job) do
      described_class.perform_later({ defendant_id: 'LONG-UUID' })
    end

    it 'queues a call to update the laa reference' do
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a LaaReferenceUnlinker and calls it' do
      expect(LaaReferenceUnlinker).to receive(:call).once.with(defendant_id: 'LONG-UUID')
      perform_enqueued_jobs { job }
    end
  end
end
