# frozen_string_literal: true

RSpec.describe HearingsCreatorJob, type: :job do
  include ActiveJob::TestHelper
  let(:argument_hash) do
    {
      hearing: {},
      sharedTime: 'DATETIME'
    }
  end

  describe '#perform_later' do
    subject(:job) do
      described_class.perform_later(body: argument_hash, request_id: 'XYZ')
    end

    it 'queues a call to publish the hearing' do
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a HearingsCreator object and calls it' do
      expect(HearingsCreator).to receive(:call).once.with(argument_hash).and_call_original
      perform_enqueued_jobs { job }
    end

    it 'sets the request_id on the Current singleton' do
      expect(Current).to receive(:set).with(request_id: 'XYZ')
      perform_enqueued_jobs { job }
    end
  end
end
