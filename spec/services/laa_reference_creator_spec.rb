# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe LaaReferenceCreator do
  include ActiveSupport::Testing::TimeHelpers

  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { '8cd0ba7e-df89-45a3-8c61-4008a2186d64' }
  let(:prosecution_case_id) { '7a0c947e-97b4-4c5a-ae6a-26320afc914d' }
  let(:laa_reference) { LaaReference.last }
  let(:user_name) { 'caseWorker' }
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

  subject(:create) { described_class.call(maat_reference: maat_reference, user_name: user_name, defendant_id: defendant_id) }

  it 'creates an LaaReference' do
    expect {
      create
    }.to change(LaaReference, :count).by(1)
  end

  it 'sets the LaaReference attributes' do
    create
    expect(laa_reference.defendant_id).to eq(defendant_id)
    expect(laa_reference.maat_reference).to eq('12345678')
    expect(laa_reference.dummy_maat_reference).to be_falsey
  end

  it 'enqueues a PastHearingsFetcherWorker' do
    Sidekiq::Testing.fake! do
      freeze_time do
        Current.set(request_id: 'XYZ') do
          expect(PastHearingsFetcherWorker).to receive(:perform_at).with(30.seconds.from_now, 'XYZ', prosecution_case_id).and_call_original
          subject
        end
      end
    end
  end

  it 'calls the Api::RecordLaaReference service once' do
    expect(Api::RecordLaaReference).to receive(:call).once.with(hash_including(application_reference: maat_reference))
    create
  end

  it 'calls the Sqs::PublishLaaReference service once' do
    expect(Sqs::PublishLaaReference).to receive(:call).once.with(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: maat_reference, user_name: user_name)
    create
  end

  context 'when an LaaReference exists' do
    let!(:existing_laa_reference) { LaaReference.create!(defendant_id: SecureRandom.uuid, user_name: 'MrDoe', maat_reference: maat_reference) }

    it 'raises an ActiveRecord::RecordInvalid error' do
      expect {
        create
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context 'that is no longer linked' do
      before do
        existing_laa_reference.update!(linked: false)
      end

      it 'creates an LaaReference' do
        expect {
          create
        }.to change(LaaReference, :count).by(1)
      end
    end
  end

  context 'with multiple offences' do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it 'calls the Sqs::PublishLaaReference service once' do
      expect(Sqs::PublishLaaReference).to receive(:call).once.with(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: maat_reference, user_name: user_name)
      create
    end

    it 'calls the Api::RecordLaaReference service multiple times' do
      expect(Api::RecordLaaReference).to receive(:call).twice.with(hash_including(application_reference: maat_reference))
      create
    end
  end

  context 'with no user name' do
    let(:user_name) { nil }
    it 'calls the Sqs::PublishLaaReference service once with user_name as cpUser' do
      expect(Sqs::PublishLaaReference).to receive(:call).once.with(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: maat_reference, user_name: 'cpUser')
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

    it 'sets creates a dummy_maat_reference' do
      create
      expect(laa_reference.defendant_id).to eq(defendant_id)
      expect(laa_reference.maat_reference).to eq('A10000000')
      expect(laa_reference.dummy_maat_reference).to be_truthy
    end
  end
end
