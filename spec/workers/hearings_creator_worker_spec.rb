# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe HearingsCreatorWorker, type: :worker do
  let(:hearing_id) { '04180ff1-99b0-40b7-9929-ca05bdc767d8' }
  let(:request_id) { 'XYZ' }

  before do
    Hearing.create!(id: hearing_id, body: JSON.parse(file_fixture('valid_hearing.json').read))
  end

  subject(:work) do
    described_class.perform_async(request_id, hearing_id)
  end

  it 'queues the job' do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it 'creates a HearingsCreator and calls with a transformed hash' do
    Sidekiq::Testing.inline! do
      expect(HearingsCreator).to receive(:call).once.with(hearing_id: hearing_id).and_call_original
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
