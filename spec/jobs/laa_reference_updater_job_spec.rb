# frozen_string_literal: true

RSpec.describe LaaReferenceUpdaterJob, type: :job do
  include ActiveJob::TestHelper
  describe '#perform_later' do
    let(:mock_laa_reference_updater) { double LaaReferenceUpdater }

    before { allow(LaaReferenceUpdater).to receive(:new).and_return(mock_laa_reference_updater) }

    subject(:job) do
      described_class.perform_later(contact: 'contract')
    end

    it 'queues a call to update the laa reference' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a LaaReferenceUpdater and calls it' do
      expect(mock_laa_reference_updater).to receive(:call).once
      perform_enqueued_jobs { job }
    end
  end
end
