# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe HearingsCreatorWorker, type: :worker do
  let(:hearing_hash) do
    {
      'prosecutionCases' => [{
        'defendants' => {}
      }]
    }
  end

  let(:transformed_hearing_hash) do
    {
      prosecutionCases: [{
        defendants: {
        }
      }]
    }
  end
  let(:shared_time) { '2020-06-16' }
  let(:request_id) { 'XYZ' }

  subject(:work) do
    described_class.perform_async(request_id, hearing_hash, shared_time)
  end

  it 'queues the job' do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it 'creates a HearingsCreator and calls with a transformed hash' do
    Sidekiq::Testing.inline! do
      expect(HearingsCreator).to receive(:call).once.with(hearing: transformed_hearing_hash, shared_time: shared_time).and_call_original
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
