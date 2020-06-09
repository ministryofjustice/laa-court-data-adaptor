# frozen_string_literal: true

RSpec.describe HearingsCreator do
  let(:defendant_array) do
    [{ 'id': 'defendant_one_id',
       'laaApplnReference': { 'applicationReference': '123456789' } }]
  end
  let(:prosecution_case_array) do
    [
      {
        prosecutionCaseIdentifier: {
          caseURN: '12345'
        },
        defendants: defendant_array
      }
    ]
  end
  let(:shared_time) { '2018-10-25 11:30:00' }
  let(:hearing) do
    {
      jurisdictionType: 'MAGISTRATES',
      courtCentre: {
        ouCode: 'B16BG00'
      },
      prosecutionCases: prosecution_case_array
    }
  end

  before { allow(Sqs::PublishHearing).to receive(:call) }

  subject(:create) { described_class.call(sharedTime: shared_time, hearing: hearing) }

  context 'with one defendant' do
    it 'calls the Sqs::PublishHearing service once' do
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                             jurisdiction_type: 'MAGISTRATES',
                                                                             case_urn: '12345',
                                                                             defendant: defendant_array.first,
                                                                             cjs_location: 'B16BG'))
      create
    end
  end

  context 'with two defendants' do
    let(:defendant_array) do
      [
        { 'id': 'defendant_one_id',
          'laaApplnReference': { 'applicationReference': '123456789' } },
        { 'id': 'defendant_two_id',
          'laaApplnReference': { 'applicationReference': '987654321' } }
      ]
    end

    it 'calls the Sqs::PublishLaaReference service twice' do
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                             jurisdiction_type: 'MAGISTRATES',
                                                                             case_urn: '12345',
                                                                             defendant: defendant_array.first,
                                                                             cjs_location: 'B16BG'))
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                             jurisdiction_type: 'MAGISTRATES',
                                                                             case_urn: '12345',
                                                                             defendant: defendant_array.last,
                                                                             cjs_location: 'B16BG'))
      create
    end
  end

  context 'with two prosecution cases' do
    let(:prosecution_case_array) do
      [
        {
          prosecutionCaseIdentifier: {
            caseURN: '12345'
          },
          defendants: defendant_array
        },
        {
          prosecutionCaseIdentifier: {
            caseURN: '54321'
          },
          defendants: defendant_array
        }
      ]
    end

    it 'calls the Sqs::PublishHearing service twice' do
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                             jurisdiction_type: 'MAGISTRATES',
                                                                             case_urn: '12345',
                                                                             defendant: defendant_array.first,
                                                                             cjs_location: 'B16BG'))
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                             jurisdiction_type: 'MAGISTRATES',
                                                                             case_urn: '54321',
                                                                             defendant: defendant_array.first,
                                                                             cjs_location: 'B16BG'))
      create
    end
  end

  context 'with a crown court hearing' do
    let(:hearing) do
      {
        jurisdictionType: 'CROWN',
        courtCentre: {
          ouCode: 'B16BG00'
        },
        prosecutionCases: prosecution_case_array
      }
    end

    it 'calls the Sqs::PublishHearing service' do
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                             jurisdiction_type: 'CROWN',
                                                                             case_urn: '12345',
                                                                             defendant: defendant_array.first,
                                                                             cjs_location: 'B16BG'))
      create
    end
  end

  context 'with a dummy MAAT ID' do
    let(:defendant_array) do
      [
        { 'id': 'defendant_one_id',
          'laaApplnReference': { 'applicationReference': 'A123456789' } },
        { 'id': 'defendant_two_id',
          'laaApplnReference': { 'applicationReference': 'Z987654321' } }
      ]
    end

    it 'does not call the Sqs::PublishHearing service' do
      expect(Sqs::PublishHearing).not_to receive(:call)
      create
    end
  end
end
