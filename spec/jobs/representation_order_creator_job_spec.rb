# frozen_string_literal: true

RSpec.describe RepresentationOrderCreatorJob, type: :job do
  include ActiveJob::TestHelper
  let(:argument_hash) do
    {
      offence_id: 'LONG-UUID',
      status_code: 'ABC',
      maat_reference: 'STRING',
      effective_start_date: 'DATE',
      effective_end_date: 'DATE',
      defence_organisation: 'HASH'
    }
  end
  describe '#perform_later' do
    subject(:job) do
      described_class.perform_later(argument_hash)
    end

    it 'queues a call to update the laa reference' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a RepresentationOrderCreator and calls it' do
      expect(RepresentationOrderCreator).to receive(:call).once.with(argument_hash)
      perform_enqueued_jobs { job }
    end
  end
end
