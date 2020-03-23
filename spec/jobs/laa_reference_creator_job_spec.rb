# frozen_string_literal: true

RSpec.describe LaaReferenceCreatorJob, type: :job do
  include ActiveJob::TestHelper
  describe '#perform_later' do
    subject(:job) do
      described_class.perform_later({ defendant_id: 'LONG-UUID' })
    end

    it 'queues a call to update the laa reference' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a LaaReferenceCreator and calls it' do
      expect(LaaReferenceCreator).to receive(:call).once.with(defendant_id: 'LONG-UUID')
      perform_enqueued_jobs { job }
    end
  end
end
