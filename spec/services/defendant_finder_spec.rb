# frozen_string_literal: true

RSpec.describe DefendantFinder do
  let(:defendant_id) { '2ecc9feb-9407-482f-b081-d9e5c8ba3ed3' }
  let(:offence_id) { '3f153786-f3cf-4311-bc0c-2d6f48af68a1' }

  subject { described_class.call(defendant_id: defendant_id) }

  let(:prosecution_case_hash) do
    JSON.parse(file_fixture('prosecution_case_search_result.json').read)['cases'][0]
  end

  context 'the defendant does exist' do
    let!(:prosecution_case) { ProsecutionCase.create!(id: '5edd67eb-9d8c-44f2-a57e-c8d026defaa4', body: prosecution_case_hash) }
    let!(:case_defendant_offence) { ProsecutionCaseDefendantOffence.create(defendant_id: defendant_id, prosecution_case_id: prosecution_case.id, offence_id: offence_id) }

    it 'returns a Defendant' do
      expect(subject).to be_a(Defendant)
    end

    it 'returns the requested Defendant' do
      expect(subject.id).to eq(defendant_id)
    end
  end

  context 'the defendant does not exist' do
    let(:defendant_id) { '2ecc9feb' }

    it 'does not return the requested Defendant' do
      expect(subject).to be_nil
    end
  end
end
