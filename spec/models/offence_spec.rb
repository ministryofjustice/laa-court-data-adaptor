# frozen_string_literal: true

RSpec.describe Offence, type: :model do
  subject(:offence) { described_class.new(body: offence_hash, details: details_array) }

  let(:offence_hash) do
    {
      "offenceId" => "db1cc378-a0e9-4943-bc36-7b34e47ae943",
      "offenceCode" => "AA06001",
      "orderIndex" => 1,
      "offenceTitle" => "Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility",
      "offenceLegislation" => "Offences against the Person Act 1861 s.24",
      "wording" => "Random string",
      "arrestDate" => "2020-02-01",
      "chargeDate" => "2020-02-01",
      "dateOfInformation" => "2020-02-01",
      "modeOfTrial" => "Indictable-Only Offence",
      "startDate" => "2020-02-01",
      "endDate" => "2020-02-01",
      "proceedingsConcluded" => false,
      "verdict" => {
        "verdictDate" => "2020-04-12",
        "originatingHearingId" => "dda833bb-4956-4c9a-a553-59c6af5c15a6",
      },
    }
  end

  let(:details_array) { nil }

  it { expect(offence.code).to eq("AA06001") }
  it { expect(offence.order_index).to eq(1) }
  it { expect(offence.title).to eq("Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility") }
  it { expect(offence.legislation).to eq("Offences against the Person Act 1861 s.24") }
  it { expect(offence.mode_of_trial).to eq("Indictable-Only Offence") }
  it { expect(offence.maat_reference).to be_nil }
  it { expect(offence.pleas).to be_an(Array).and be_empty }

  context "when an LAA reference are available" do
    subject(:offence) { described_class.new(body: offence_hash.merge(laa_reference)) }

    let(:laa_reference) do
      {
        "laaApplnReference" => {
          "applicationReference" => "AB746921",
          "statusId" => "f644b843-a0a9-4344-81c5-ec484805775c",
          "statusCode" => "GR",
          "statusDescription" => "FAKE NEWS",
          "statusDate" => "1980-07-15",
        },
      }
    end

    it { expect(offence.maat_reference).to eq("AB746921") }
  end

  describe "#pleas" do
    subject { offence.pleas }

    context "with one plea" do
      let(:details_array) do
        [{
          "plea" => {
            "pleaDate" => "2020-04-25",
            "pleaValue" => "NOT_GUILTY",
            "originatingHearingId" => "uuid-for-first-hearing",
          },
        }]
      end

      let(:plea_array) do
        [{
          "code": "NOT_GUILTY",
          "pleaded_at": "2020-04-25",
          "originating_hearing_id" => "uuid-for-first-hearing",
        }]
      end

      it { is_expected.to eq plea_array }
    end

    context "with multiple unique pleas" do
      let(:details_array) do
        [{
          "plea" => {
            "pleaDate" => "2020-04-24",
            "pleaValue" => "NOT_GUILTY",
            "originatingHearingId" => "uuid-for-first-hearing",
          },
        },
         {
           "plea" => {
             "pleaDate" => "2020-12-24",
             "pleaValue" => "GUILTY",
             "originatingHearingId" => "uuid-for-second-hearing",
           },
         }]
      end

      let(:plea_array) do
        [{
          "code": "NOT_GUILTY",
          "pleaded_at": "2020-04-24",
          "originating_hearing_id" => "uuid-for-first-hearing",
        },
         {
           "code": "GUILTY",
           "pleaded_at": "2020-12-24",
           "originating_hearing_id" => "uuid-for-second-hearing",
         }]
      end

      it { is_expected.to eq plea_array }
    end

    context "with multiple non-unique pleas" do
      let(:details_array) do
        [{
          "plea" => {
            "pleaDate" => "2020-04-24",
            "pleaValue" => "NOT_GUILTY",
            "originatingHearingId" => "uuid-for-first-hearing",
          },
        },
         {
           "plea" => {
             "pleaDate" => "2020-04-24",
             "pleaValue" => "NOT_GUILTY",
             "originatingHearingId" => "uuid-for-first-hearing",
           },
         }]
      end

      let(:plea_array) do
        [{
          "code": "NOT_GUILTY",
          "pleaded_at": "2020-04-24",
          "originating_hearing_id" => "uuid-for-first-hearing",
        }]
      end

      it { is_expected.to eq plea_array }
    end

    context "with no pleas" do
      let(:details_array) { [{ "some_other_detail" => "" }] }

      it { expect(offence.pleas).to be_an(Array).and be_empty }
    end
  end

  describe "#mode_of_trial_reasons" do
    subject(:mode_of_trial_reasons) { offence.mode_of_trial_reasons }

    context "when one allocation decision is available" do
      let(:details_array) do
        [{
          "allocationDecision" => {
            "motReasonDescription" => "Court directs trial by jury",
            "motReasonCode" => "05",
          },
        }]
      end

      let(:allocation_decisions_array) do
        [{
          description: "Court directs trial by jury",
          code: "05",
        }]
      end

      it { is_expected.to eql allocation_decisions_array }
    end

    context "when multiple unique allocation decisions are available" do
      let(:details_array) do
        [{
          "allocationDecision" => {
            "motReasonDescription" => "Court directs trial by jury",
            "motReasonCode" => "05",
          },
        },
         {
           "allocationDecision" => {
             "motReasonDescription" => "Some other mot desc",
             "motReasonCode" => "101",
           },
         }]
      end

      let(:allocation_decisions_array) do
        [{
          code: "05",
          description: "Court directs trial by jury",
        },
         {
           code: "101",
           description: "Some other mot desc",
         }]
      end

      it { is_expected.to eql allocation_decisions_array }
    end

    context "when multiple non-unique allocation decisions available across different hearings" do
      let(:details_array) do
        [{
          "allocationDecision" => {
            "motReasonDescription" => "Court directs trial by jury",
            "motReasonCode" => "05",
            "originatingHearingId" => "uuid-for-first-hearing",
          },
        },
         {
           "allocationDecision" => {
             "motReasonDescription" => "Court directs trial by jury",
             "motReasonCode" => "05",
             "originatingHearingId" => "uuid-for-second-hearing",
           },
         }]
      end

      let(:allocation_decisions_array) do
        [{
          description: "Court directs trial by jury",
          code: "05",
        }]
      end

      it { is_expected.to eql allocation_decisions_array }
    end

    context "with no allocation decisions" do
      let(:details_array) { [{ "some_other_detail" => "" }] }

      it { expect(offence.mode_of_trial_reasons).to be_an(Array).and be_empty }
    end
  end
end
