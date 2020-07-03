# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe LaaReferenceCreator do
  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { '8cd0ba7e-df89-45a3-8c61-4008a2186d64' }
  let(:prosecution_case_id) { '7a0c947e-97b4-4c5a-ae6a-26320afc914d' }
  before do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture('prosecution_case_search_result.json').read)['cases'][0]
    )
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: 'cacbd4d4-9102-4687-98b4-d529be3d5710')

    allow(Sqs::PublishLaaReference).to receive(:call)
    allow(Api::RecordLaaReference).to receive(:call)
    allow(Api::GetHearingResults).to receive(:call)
  end

  subject(:create) { described_class.call(maat_reference: maat_reference, defendant_id: defendant_id) }

  it 'calls the ProsecutionCaseHearingsFetcher' do
    expect(ProsecutionCaseHearingsFetcher).to receive(:call).with(prosecution_case_id: prosecution_case_id).and_call_original
    create
  end

  it 'calls the Api::RecordLaaReference service once' do
    expect(Api::RecordLaaReference).to receive(:call).once.with(hash_including(application_reference: maat_reference))
    create
  end

  it 'calls the Sqs::PublishLaaReference service once' do
    expect(Sqs::PublishLaaReference).to receive(:call).once.with(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: maat_reference)
    create
  end

  context 'with multiple offences' do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it 'calls the Sqs::PublishLaaReference service once' do
      expect(Sqs::PublishLaaReference).to receive(:call).once.with(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: maat_reference)
      create
    end

    it 'calls the Api::RecordLaaReference service multiple times' do
      expect(Api::RecordLaaReference).to receive(:call).twice.with(hash_including(application_reference: maat_reference))
      create
    end
  end

  context 'with no maat reference' do
    let(:maat_reference) { nil }

    before do
      ActiveRecord::Base.connection.execute('ALTER SEQUENCE dummy_maat_reference_seq RESTART;')
    end

    it 'does not call the Sqs::PublishLaaReference service' do
      expect(Sqs::PublishLaaReference).not_to receive(:call)
      create
    end

    it 'creates a dummy maat_reference' do
      expect(Api::RecordLaaReference).to receive(:call).with(hash_including(application_reference: 'A10000000'))
      create
    end
  end
end
