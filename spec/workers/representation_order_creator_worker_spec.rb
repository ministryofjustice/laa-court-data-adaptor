# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe RepresentationOrderCreatorWorker, type: :worker do
  let(:defendant_id) { 'LONG-UUID' }
  let(:offences) { [] }
  let(:maat_reference) { 123_123 }
  let(:defence_organisation) { { 'key' => 'value' } }
  let(:request_id) { 'XYZ' }

  subject(:work) do
    described_class.perform_async(request_id, defendant_id, offences, maat_reference, defence_organisation)
  end

  it 'queues the job' do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it 'creates a RepresentationOrderCreator and calls it' do
    Sidekiq::Testing.inline! do
      expect(RepresentationOrderCreator).to receive(:call).once.with(
        defendant_id: defendant_id,
        offences: offences,
        maat_reference: maat_reference,
        defence_organisation: defence_organisation
      ).and_call_original
      work
    end
  end

  it 'sets the request_id on the Current singleton' do
    Sidekiq::Testing.inline! do
      expect(Current).to receive(:set).with(request_id: 'XYZ')
      work
    end
  end
end
