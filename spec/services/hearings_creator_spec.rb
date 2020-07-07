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
  let(:application_array) do
    [
      {
        applicationReference: '12345',
        type: {
          applicationCode: 'ASE'
        },
        applicant: {
          defendant: defendant_array.first
        }
      }
    ]
  end
  let(:shared_time) { '2018-10-25 11:30:00' }
  let(:hearing) do
    {
      jurisdictionType: 'MAGISTRATES',
      courtCentre: {
        id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'
      },
      prosecutionCases: prosecution_case_array,
      courtApplications: application_array
    }
  end

  before { allow(Sqs::PublishHearing).to receive(:call) }

  subject(:create) { described_class.call(shared_time: shared_time, hearing: hearing) }

  context 'for a trial' do
    let(:application_array) { nil }

    context 'with one defendant' do
      it 'calls the Sqs::PublishHearing service once' do
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_array.first,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
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
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_array.last,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
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
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '54321',
                                                                               defendant: defendant_array.first,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        create
      end
    end

    context 'with a crown court hearing' do
      let(:hearing) do
        {
          jurisdictionType: 'CROWN',
          courtCentre: {
            id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'
          },
          prosecutionCases: prosecution_case_array
        }
      end

      it 'calls the Sqs::PublishHearing service' do
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'CROWN',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_array.first,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
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

  context 'for an appeal' do
    let(:prosecution_case_array) { nil }

    it 'calls the Sqs::PublishHearing service once' do
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                             jurisdiction_type: 'MAGISTRATES',
                                                                             case_urn: '12345',
                                                                             defendant: defendant_array.first,
                                                                             court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
      create
    end
  end
end
