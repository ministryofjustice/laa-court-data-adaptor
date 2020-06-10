# frozen_string_literal: true

RSpec.describe LaaReferenceCreatorJob, type: :job do
  include ActiveJob::TestHelper
  describe '#perform_later' do
    subject(:job) do
      described_class.perform_later(contract: { defendant_id: 'LONG-UUID' }, request_id: 'XYZ')
    end

    it 'queues a call to update the laa reference' do
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a LaaReferenceCreator and calls it' do
      expect(LaaReferenceCreator).to receive(:call).once.with(defendant_id: 'LONG-UUID')
      perform_enqueued_jobs { job }
    end

    it 'sets the request_id on the Current singleton' do
      expect(Current).to receive(:set).with(request_id: 'XYZ')
      perform_enqueued_jobs { job }
    end
  end
end
