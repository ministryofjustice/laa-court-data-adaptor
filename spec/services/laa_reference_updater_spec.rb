# frozen_string_literal: true

RSpec.describe LaaReferenceUpdater do
  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { SecureRandom.uuid }
  let(:contract) { NewLaaReferenceContract.new.call({ maat_reference: maat_reference, defendant_id: defendant_id }) }
  let(:mock_record_laa_reference_service) { instance_double Api::RecordLaaReference }

  before do
    allow(Api::RecordLaaReference).to receive(:new).and_return(mock_record_laa_reference_service)
    allow(mock_record_laa_reference_service).to receive(:call).and_return(Faraday::Response.new(status: 200, body: { 'test' => 'test' }))
  end

  before do
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: SecureRandom.uuid,
                                            defendant_id: defendant_id,
                                            offence_id: SecureRandom.uuid)
  end

  subject(:update) { described_class.call(contract) }

  it 'creates and calls the Api::RecordLaaReference service once' do
    expect(mock_record_laa_reference_service).to receive(:call).once
    update
  end

  it 'updates the ProsecutionCaseDefendantOffence record' do
    update
    offence_record = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)
    expect(offence_record.maat_reference).to eq(maat_reference.to_s)
    expect(offence_record.dummy_maat_reference).to be false
  end

  context 'with multiple offences' do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: SecureRandom.uuid,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it 'creates and calls the Api::RecordLaaReference service multiple times' do
      expect(mock_record_laa_reference_service).to receive(:call).twice
      update
    end

    it 'updates all the ProsecutionCaseDefendantOffence records' do
      update
      ProsecutionCaseDefendantOffence.where(defendant_id: defendant_id).each do |record|
        expect(record.maat_reference).to eq(maat_reference.to_s)
        expect(record.dummy_maat_reference).to be false
        expect(record.response_status).to eq(200)
        expect(record.response_body).to eq({ 'test' => 'test' })
        expect(record.user_id).to be_nil
      end
    end
  end

  context 'with no maat reference' do
    let(:maat_reference) { nil }

    before do
      ActiveRecord::Base.connection.execute('ALTER SEQUENCE dummy_maat_reference_seq RESTART;')
    end

    it 'creates a dummy maat_reference' do
      expect(Api::RecordLaaReference).to receive(:new).with(hash_including(application_reference: 'A10000000'))
      update
    end

    it 'updates the ProsecutionCaseDefendantOffence record' do
      update
      offence_record = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)
      expect(offence_record.maat_reference).to eq('A10000000')
      expect(offence_record.dummy_maat_reference).to be true
    end
  end
end
