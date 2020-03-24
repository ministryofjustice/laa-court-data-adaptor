# frozen_string_literal: true

RSpec.describe LaaReferenceUnlinker do
  let(:defendant_id) { '8cd0ba7e-df89-45a3-8c61-4008a2186d64' }
  let(:prosecution_case_id) { '7a0c947e-97b4-4c5a-ae6a-26320afc914d' }
  before do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture('prosecution_case_search_result.json').read)
    )
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: 'cacbd4d4-9102-4687-98b4-d529be3d5710')

    ActiveRecord::Base.connection.execute('ALTER SEQUENCE dummy_maat_reference_seq RESTART;')
  end

  subject(:create) { described_class.call(defendant_id: defendant_id) }

  it 'creates a dummy maat_reference starting with Z' do
    expect(Api::RecordLaaReference).to receive(:call).with(hash_including(application_reference: 'Z10000000'))
    create
  end

  context 'with multiple offences' do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it 'calls the Api::RecordLaaReference service multiple times' do
      expect(Api::RecordLaaReference).to receive(:call).twice.with(hash_including(application_reference: 'Z10000000'))
      create
    end
  end
end
