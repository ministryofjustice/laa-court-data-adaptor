# frozen_string_literal: true

RSpec.describe HearingsCreator do
  subject(:create_hearings) { described_class.call(hearing_id: hearing.id) }

  let(:defendant_array) { [defendant_one] }
  let(:offence_array) { [offence_one, offence_two] }

  let(:maat_reference) { "123456789" }

  let(:defendant_one) do
    {
      "id": "dd22b110-7fbc-3036-a076-e4bb40d0a888",
      "offences": offence_array,
    }
  end

  let(:offence_one) do
    {
      "laaApplnReference": {
        "applicationReference": maat_reference,
      },
    }
  end

  let(:offence_two) do
    {
      "laaApplnReference": {
        "applicationReference": maat_reference,
      },
    }
  end

  let(:defendant_two) do
    {
      "id": "dd22b110-7fbc-3036-a076-e4bb40d0a899",
      "offences": [{
        "laaApplnReference": {
          "applicationReference": "987654321",
        },
      }],
    }
  end

  let(:prosecution_case_array) do
    [
      {
        "prosecutionCaseIdentifier": {
          "caseURN": "12345",
        },
        "defendants": defendant_array,
      },
    ]
  end
  let(:applications_array) do
    [
      {
        "applicationReference": "12345",
        "type": {
          "applicationCode": "ASE",
        },
        "applicant": {
          "defendant": defendant_one,
        },
      },
    ]
  end
  let(:hearing_body) do
    {
      "hearing": {
        "jurisdictionType": "MAGISTRATES",
        "courtCentre": {
          "id": "dd22b110-7fbc-3036-a076-e4bb40d0a519",
        },
        "prosecutionCases": prosecution_case_array,
        "courtApplications": applications_array,
      },
      "sharedTime": "2018-10-25 11:30:00",
    }
  end

  let(:hearing) { Hearing.create!(body: hearing_body) }

  before { allow(Sqs::MessagePublisher).to receive(:call) }

  describe "a prosecution case" do
    let(:applications_array) { nil }

    context "with one defendant" do
      it "calls the Sqs::MessagePublisher service once" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a888", linked: true, maat_reference: "123", user_name: "Bob")

        expect(Sqs::MessagePublisher).to receive(:call).once

        create_hearings
      end
    end

    context "with two defendants" do
      let(:defendant_array) do
        [defendant_one, defendant_two]
      end

      it "calls the Sqs::PublishLaaReference service twice" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a888", linked: true, maat_reference: "123", user_name: "Bob")
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a899", linked: true, maat_reference: "456", user_name: "Steve")

        expect(Sqs::MessagePublisher).to receive(:call).twice

        create_hearings
      end
    end

    context "with two prosecution cases" do
      let(:prosecution_case_array) do
        [
          {
            "prosecutionCaseIdentifier": {
              "caseURN": "12345",
            },
            "defendants": defendant_array,
          },
          {
            "prosecutionCaseIdentifier": {
              "caseURN": "54321",
            },
            "defendants": defendant_array,
          },
        ]
      end

      it "calls the Sqs::MessagePublisher service twice" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a888", linked: true, maat_reference: "123", user_name: "Bob")

        expect(Sqs::MessagePublisher).to receive(:call).twice

        create_hearings
      end
    end

    context "with a crown court hearing" do
      let(:hearing_body) do
        {
          "hearing": {
            "jurisdictionType": "CROWN",
            "courtCentre": {
              "id": "dd22b110-7fbc-3036-a076-e4bb40d0a519",
            },
            "prosecutionCases": prosecution_case_array,
          },
          "sharedTime": "2018-10-25 11:30:00",
        }
      end

      it "calls the Sqs::MessagePublisher service" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a888", linked: true, maat_reference: "123", user_name: "Bob")

        expect(Sqs::MessagePublisher).to receive(:call).once

        create_hearings
      end
    end

    context "with a dummy MAAT ID" do
      let(:maat_reference) { "A123456789" }

      it "does not call the Sqs::MessagePublisher service" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a888", linked: true, maat_reference: "123", user_name: "Bob")

        expect(Sqs::MessagePublisher).not_to receive(:call)
        create_hearings
      end
    end
  end

  describe "an appeal" do
    let(:prosecution_case_array) { nil }

    it "calls the Sqs::PublishHearing service once" do
      expect(Sqs::PublishHearing).to receive(:call).once.with(hash_including(shared_time: "2018-10-25 11:30:00",
                                                                             jurisdiction_type: "MAGISTRATES",
                                                                             case_urn: "12345",
                                                                             defendant: defendant_one,
                                                                             court_centre_id: "dd22b110-7fbc-3036-a076-e4bb40d0a519"))
      create_hearings
    end
  end

  describe "an application to court" do
    let(:court_application) do
      {
        "applicationReference": "12345",
        "type": {
          "applicationCode": "ASE",
        },
        "applicant": {
          "masterDefendant": {
            "defendantCase":
            [
              { "defendantId": "dd22b110-7fbc-3036-a076-e4bb40d0a666" },
              { "defendantId": "ad22b110-7fbc-3036-a076-e4bb40d0a667" },
            ],
          },
        },
      }
    end

    let(:applications_array) { [court_application] }

    context "with one linked defendant" do
      let(:prosecution_case_array) { nil }

      it "calls the Sqs::MessagePublisher service once" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a666", linked: true, maat_reference: "123", user_name: "Bob")

        expect(Sqs::MessagePublisher).to receive(:call).once

        create_hearings
      end
    end

    context "with two linked defendants" do
      let(:prosecution_case_array) { nil }
      let(:defendant_case_array) { [defendant_case_one, defendant_case_two] }

      it "calls the Sqs::MessagePublisher service twice" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a666", linked: true, maat_reference: "123", user_name: "Bob")
        LaaReference.create!(defendant_id: "ad22b110-7fbc-3036-a076-e4bb40d0a667", linked: true, maat_reference: "456", user_name: "Steve")

        expect(Sqs::MessagePublisher).to receive(:call).twice

        create_hearings
      end
    end

    context "with two defendants, one with linked LAA reference, one without" do
      let(:prosecution_case_array) { nil }
      let(:defendant_case_array) { [defendant_case_one, defendant_case_two] }

      it "calls the Sqs::MessagePublisher service once" do
        LaaReference.create!(defendant_id: "dd22b110-7fbc-3036-a076-e4bb40d0a666", linked: true, maat_reference: "123", user_name: "Bob")
        LaaReference.create!(defendant_id: "ad22b110-7fbc-3036-a076-e4bb40d0a667", linked: false, maat_reference: "456", user_name: "Steve")

        expect(Sqs::MessagePublisher).to receive(:call).once

        create_hearings
      end
    end

    context "with no defendant cases" do
      let(:prosecution_case_array) { nil }
      let(:defendant_case_array) { nil }

      it "does not call the Sqs::MessagePublisher service" do
        expect(Sqs::MessagePublisher).not_to receive(:call)

        create_hearings
      end
    end

    context "with a defendant that has no LAA reference" do
      let(:prosecution_case_array) { nil }

      it "does not call the Sqs::MessagePublisher service" do
        allow(LaaReference).to receive(:find_by).and_return(nil)

        expect(Sqs::MessagePublisher).not_to receive(:call)

        create_hearings
      end
    end
  end
end
