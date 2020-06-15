# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe LaaReferenceCreatorWorker, type: :worker do
  let(:defendant_id) { 'LONG-UUID' }
  let(:maat_reference) { nil }
  let(:request_id) { 'XYZ' }

  subject(:work) do
    described_class.perform_async(request_id, defendant_id, maat_reference)
  end

  it 'queues the job' do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it 'creates a LaaReferenceCreator and calls it' do
    Sidekiq::Testing.inline! do
      expect(LaaReferenceCreator).to receive(:call).once.with(defendant_id: defendant_id, maat_reference: nil).and_call_original
      work
    end
  end

  context 'with a non-nil maat_reference' do
    let(:maat_reference) { 909_090 }
    it 'creates a LaaReferenceCreator and calls it' do
      Sidekiq::Testing.inline! do
        expect(LaaReferenceCreator).to receive(:call).once.with(defendant_id: defendant_id, maat_reference: 909_090)
        work
      end
    end
  end

  it 'sets the request_id on the Current singleton' do
    Sidekiq::Testing.inline! do
      expect(Current).to receive(:set).with(request_id: 'XYZ')
      work
    end
  end
end
