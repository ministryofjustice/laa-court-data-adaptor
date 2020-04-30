# frozen_string_literal: true

RSpec.describe HearingsCreator do
  let(:defendant_array) { [{ 'id': 'defendant_one_id' }] }
  let(:prosecution_case_array) do
    [
      {
        caseStatus: 'Open',
        caseURN: '12345',
        defendants: defendant_array
      }
    ]
  end

  let(:mags_hearing) do
    {
      hearing:
      {
        jurisdictionType: 'MAGISTRATES',
        prosecutionCases: prosecution_case_array
      },
      sharedTime: '2018-10-25 11:30:00'
    }
  end

  before { allow(Sqs::PublishMagistratesHearing).to receive(:call) }

  context 'with one defendant' do
    subject(:create) { described_class.call(hearing: mags_hearing) }

    it 'calls the Sqs::PublishMagistratesHearing service once' do
      expect(Sqs::PublishMagistratesHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                                        jurisdiction_type: 'MAGISTRATES',
                                                                                        case_status: 'Open',
                                                                                        case_urn: '12345',
                                                                                        defendant: defendant_array.first))
      create
    end
  end

  context 'with two defendants' do
    let(:defendant_array) do
      [
        {
          'id': 'defendant_one_id'
        },
        {
          'id': 'defendant_two_id'
        }
      ]
    end

    subject(:create) { described_class.call(hearing: mags_hearing) }

    it 'calls the Sqs::PublishLaaReference service twice' do
      expect(Sqs::PublishMagistratesHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                                        jurisdiction_type: 'MAGISTRATES',
                                                                                        case_status: 'Open',
                                                                                        case_urn: '12345',
                                                                                        defendant: defendant_array.first))
      expect(Sqs::PublishMagistratesHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                                        jurisdiction_type: 'MAGISTRATES',
                                                                                        case_status: 'Open',
                                                                                        case_urn: '12345',
                                                                                        defendant: defendant_array.last))
      create
    end
  end

  context 'with two prosecution cases' do
    let(:prosecution_case_array) do
      [
        {
          caseStatus: 'Open',
          caseURN: '12345',
          defendants: defendant_array
        },
        {
          caseStatus: 'Closed',
          caseURN: '54321',
          defendants: defendant_array
        }
      ]
    end

    subject(:create) { described_class.call(hearing: mags_hearing) }

    it 'calls the Sqs::PublishMagistratesHearing service twice' do
      expect(Sqs::PublishMagistratesHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                                        jurisdiction_type: 'MAGISTRATES',
                                                                                        case_status: 'Open',
                                                                                        case_urn: '12345',
                                                                                        defendant: defendant_array.first))
      expect(Sqs::PublishMagistratesHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                                        jurisdiction_type: 'MAGISTRATES',
                                                                                        case_status: 'Closed',
                                                                                        case_urn: '54321',
                                                                                        defendant: defendant_array.first))
      create
    end

    context 'with a crown court hearing' do
      let(:mags_hearing) do
        {
          hearing:
          {
            jurisdictionType: 'CROWN',
            prosecutionCases: prosecution_case_array
          },
          sharedTime: '2018-10-25 11:30:00'
        }
      end

      it 'does not call the Sqs::PublishMagistratesHearing service' do
        expect(Sqs::PublishMagistratesHearing).not_to receive(:call)
        create
      end
    end
  end
end
