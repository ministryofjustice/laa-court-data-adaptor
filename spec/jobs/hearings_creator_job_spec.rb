# frozen_string_literal: true

RSpec.describe HearingsCreatorJob, type: :job do
  include ActiveJob::TestHelper
  let(:argument_hash) do
    {
      hearing: 'HASH',
      sharedTime: 'DATETIME'
    }
  end

  describe '#perform_later' do
    subject(:job) do
      described_class.perform_later(argument_hash)
    end

    it 'queues a call to publish the hearing' do
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a HearingsCreator object and calls it' do
      expect(HearingsCreator).to receive(:call).once.with(argument_hash)
      perform_enqueued_jobs { job }
    end
  end
end
