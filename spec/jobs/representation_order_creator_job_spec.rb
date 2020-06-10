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
      described_class.perform_later(contract: argument_hash, request_id: 'XYZ')
    end

    it 'queues a call to update the laa reference' do
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a RepresentationOrderCreator and calls it' do
      expect(RepresentationOrderCreator).to receive(:call).once.with(argument_hash)
      perform_enqueued_jobs { job }
    end

    it 'sets the request_id on the Current singleton' do
      allow(RepresentationOrderCreator).to receive(:call)
      expect(Current).to receive(:set).with(request_id: 'XYZ')
      perform_enqueued_jobs { job }
    end
  end
end
