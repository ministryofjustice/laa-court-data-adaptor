# frozen_string_literal: true

RSpec.describe LaaReferenceUpdater do
  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { SecureRandom.uuid }
  let(:contract) { NewLaaReferenceContract.new.call({ maat_reference: maat_reference, defendant_id: defendant_id }) }
  let(:mock_record_laa_reference_service) { instance_double Api::RecordLaaReference }

  before do
    allow(Api::RecordLaaReference).to receive(:new).and_return(mock_record_laa_reference_service)
    allow(mock_record_laa_reference_service).to receive(:call)
  end

  before do
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: SecureRandom.uuid,
                                            defendant_id: defendant_id,
                                            offence_id: SecureRandom.uuid)
  end

  subject(:record) { described_class.call(contract) }

  it 'creates and calls the Api::RecordLaaReference service once' do
    expect(mock_record_laa_reference_service).to receive(:call).once
    record
  end

  context 'with multiple offences' do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: SecureRandom.uuid,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it 'creates and calls the Api::RecordLaaReference service multiple times' do
      expect(mock_record_laa_reference_service).to receive(:call).twice
      record
    end
  end

  context 'with no maat reference' do
    let(:maat_reference) { nil }

    before do
      ActiveRecord::Base.connection.execute('ALTER SEQUENCE dummy_maat_reference_seq RESTART;')
    end

    it 'creates a dummy maat_reference' do
      expect(Api::RecordLaaReference).to receive(:call).with(hash_including(application_reference: 'A10000000'))
      subject
    end
  end
end
