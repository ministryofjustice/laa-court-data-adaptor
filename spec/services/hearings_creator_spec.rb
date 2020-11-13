# frozen_string_literal: true

RSpec.describe HearingsCreator do
  let(:defendant_array) { [defendant_one] }
  let(:offence_array) { [offence_one, offence_two] }

  let(:maat_reference) { '123456789' }

  let(:defendant_one) do
    { "offences": offence_array }
  end

  let(:offence_one) do
    {
      "laaApplnReference": {
        "applicationReference": maat_reference
      }
    }
  end

  let(:offence_two) do
    {
      "laaApplnReference": {
        "applicationReference": maat_reference
      }
    }
  end

  let(:defendant_two) do
    {
      "offences": [{
        "laaApplnReference": {
          "applicationReference": '987654321'
        }
      }]
    }
  end

  let(:prosecution_case_array) do
    [
      {
        "prosecutionCaseIdentifier": {
          "caseURN": '12345'
        },
        "defendants": defendant_array
      }
    ]
  end
  let(:applications_array) do
    [
      {
        "applicationReference": '12345',
        "type": {
          "applicationCode": 'ASE'
        },
        "applicant": {
          "defendant": defendant_one
        }
      }
    ]
  end
  let(:hearing_body) do
    {
      "hearing": {
        "jurisdictionType": 'MAGISTRATES',
        "courtCentre": {
          "id": 'dd22b110-7fbc-3036-a076-e4bb40d0a519'
        },
        "prosecutionCases": prosecution_case_array,
        "courtApplications": applications_array
      },
      "sharedTime": '2018-10-25 11:30:00'
    }
  end

  let(:hearing) { Hearing.create!(body: hearing_body) }

  before { allow(Sqs::PublishHearing).to receive(:call) }

  subject(:create) { described_class.call(hearing_id: hearing.id) }

  context 'for a trial' do
    let(:applications_array) { nil }

    context 'with one defendant' do
      it 'calls the Sqs::PublishHearing service once' do
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_one,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        create
      end
    end

    context 'when an laaApplnReference does not exist' do
      let(:offence_two) do
        {}
      end

      it 'calls the Sqs::PublishHearing service once' do
        expect(Sqs::PublishHearing).to receive(:call).once
        create
      end
    end

    context 'with two defendants' do
      let(:defendant_array) do
        [defendant_one, defendant_two]
      end

      it 'calls the Sqs::PublishLaaReference service twice' do
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_one,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_two,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        create
      end
    end

    context 'with two prosecution cases' do
      let(:prosecution_case_array) do
        [
          {
            "prosecutionCaseIdentifier": {
              "caseURN": '12345'
            },
            "defendants": defendant_array
          },
          {
            "prosecutionCaseIdentifier": {
              "caseURN": '54321'
            },
            "defendants": defendant_array
          }
        ]
      end

      it 'calls the Sqs::PublishHearing service twice' do
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_one,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'MAGISTRATES',
                                                                               case_urn: '54321',
                                                                               defendant: defendant_one,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        create
      end
    end

    context 'with a crown court hearing' do
      let(:hearing_body) do
        {
          "hearing": {
            "jurisdictionType": 'CROWN',
            "courtCentre": {
              "id": 'dd22b110-7fbc-3036-a076-e4bb40d0a519'
            },
            "prosecutionCases": prosecution_case_array
          },
          "sharedTime": '2018-10-25 11:30:00'
        }
      end

      it 'calls the Sqs::PublishHearing service' do
        expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: '2018-10-25 11:30:00',
                                                                               jurisdiction_type: 'CROWN',
                                                                               case_urn: '12345',
                                                                               defendant: defendant_one,
                                                                               court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
        create
      end
    end

    context 'with a dummy MAAT ID' do
      let(:maat_reference) { 'A123456789' }

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
                                                                             defendant: defendant_one,
                                                                             court_centre_id: 'dd22b110-7fbc-3036-a076-e4bb40d0a519'))
      create
    end

    context 'when an laaApplnReference does not exist' do
      let(:offence_two) do
        {}
      end

      it 'calls the Sqs::PublishHearing service once' do
        expect(Sqs::PublishHearing).to receive(:call).once
        create
      end
    end
  end
end
