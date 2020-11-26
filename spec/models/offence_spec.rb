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
    }
  end

  let(:details_array) { nil }

  it { expect(offence.code).to eq("AA06001") }
  it { expect(offence.order_index).to eq(1) }
  it { expect(offence.title).to eq("Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility") }
  it { expect(offence.legislation).to eq("Offences against the Person Act 1861 s.24") }
  it { expect(offence.mode_of_trial).to eq("Indictable-Only Offence") }
  it { expect(offence.maat_reference).to be_nil }
  it { expect(offence.plea).to be_nil }
  it { expect(offence.plea_date).to be_nil }
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

  context "when plea details are available" do
    let(:details_array) do
      [{
        "plea" => {
          "pleaDate" => "2020-04-24",
          "pleaValue" => "GUILTY",
        },
      }]
    end

    describe "#plea" do
      subject { offence.plea }

      it { is_expected.to eq("GUILTY") }
    end

    describe "#plea_date" do
      subject { offence.plea_date }

      it { is_expected.to eq("2020-04-24") }
    end

    context "#pleas" do
      subject { offence.pleas }

      let(:plea_array) do
        [{
          "code": "GUILTY",
          "pleaded_at": "2020-04-24",
        }]
      end

      it { is_expected.to eq plea_array }

      context "with multiple pleas" do
        let(:details_array) do
          [{
            "plea" => {
              "pleaDate" => "2020-04-24",
              "pleaValue" => "NOT_GUILTY",
            },
          },
           {
             "plea" => {
               "pleaDate" => "2020-12-24",
               "pleaValue" => "GUILTY",
             },
           }]
        end

        let(:plea_array) do
          [{
            "code": "NOT_GUILTY",
            "pleaded_at": "2020-04-24",
          },
           {
             "code": "GUILTY",
             "pleaded_at": "2020-12-24",
           }]
        end

        it { is_expected.to eq plea_array }
      end

      context "with no pleas" do
        let(:details_array) { [{ "some_other_detail" => "" }] }

        it { expect(offence.pleas).to be_an(Array).and be_empty }
      end
    end
  end

  describe "#mode_of_trial_reason" do
    subject(:mode_of_trial_reason) { offence.mode_of_trial_reason }

    context "when an allocation decision is not available" do
      let(:details_array) { {} }

      it { is_expected.to be_nil }
    end

    context "when an allocation decision is available" do
      let(:details_array) do
        [{
          "allocationDecision" => {
            "motReasonDescription" => "Court directs trial by jury",
          },
        }]
      end

      it { is_expected.to eql "Court directs trial by jury" }
    end
  end

  describe "#mode_of_trial_reason_code" do
    subject(:mode_of_trial_reason) { offence.mode_of_trial_reason_code }

    context "when an allocation decision is not available" do
      let(:details_array) { {} }

      it { is_expected.to be_nil }
    end

    context "when an allocation decision is available" do
      let(:details_array) do
        [{
          "allocationDecision" => {
            "motReasonCode" => "5",
          },
        }]
      end

      it { is_expected.to eql "5" }
    end
  end
end
