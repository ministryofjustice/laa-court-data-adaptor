# frozen_string_literal: true

RSpec.describe LaaReferenceUpdaterJob, type: :job do
  include ActiveJob::TestHelper
  describe '#perform_later' do
    let(:mock_laa_reference_recorder) { double Api::RecordLaaReference }

    before { allow(Api::RecordLaaReference).to receive(:new).and_return(mock_laa_reference_recorder) }

    subject(:job) do
      described_class.perform_later(
        prosecution_case_id: SecureRandom.uuid,
        defendant_id: SecureRandom.uuid,
        offence_id: SecureRandom.uuid,
        status_code: 'AP',
        application_reference: '123456789',
        status_date: Date.today.strftime('%Y-%m-%d')
      )
    end

    it 'queues a call to update the laa reference' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        job
      }.to have_enqueued_job
    end

    it 'creates a RecordLaaReference and calls it' do
      expect(mock_laa_reference_recorder).to receive(:call).once
      perform_enqueued_jobs { job }
    end
  end
end
