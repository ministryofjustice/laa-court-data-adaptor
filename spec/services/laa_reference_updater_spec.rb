# frozen_string_literal: true

RSpec.describe LaaReferenceUpdater do
  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { SecureRandom.uuid }
  let(:contract) { NewLaaReferenceContract.new.call({ maat_reference: maat_reference, defendant_id: defendant_id }) }
  let(:mock_record_laa_reference_service) { double Api::RecordLaaReference }

  before { allow(Api::RecordLaaReference).to receive(:new).and_return(mock_record_laa_reference_service) }

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
end
