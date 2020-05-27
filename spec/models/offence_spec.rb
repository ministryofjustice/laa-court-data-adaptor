# frozen_string_literal: true

RSpec.describe Offence, type: :model do
  let(:offence_hash) do
    {
      'offenceId' => 'db1cc378-a0e9-4943-bc36-7b34e47ae943',
      'offenceCode' => 'AA06001',
      'orderIndex' => 1,
      'offenceTitle' => 'Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility',
      'offenceLegislation' => 'N/A',
      'wording' => 'Random string',
      'arrestDate' => '2020-02-01',
      'chargeDate' => '2020-02-01',
      'dateOfInformation' => '2020-02-01',
      'modeOfTrial' => 'Indictable-Only Offence',
      'startDate' => '2020-02-01',
      'endDate' => '2020-02-01',
      'proceedingsConcluded' => false
    }
  end

  let(:details_hash) { nil }

  subject(:offence) { described_class.new(body: offence_hash, details: details_hash) }

  it { expect(offence.code).to eq('AA06001') }
  it { expect(offence.order_index).to eq(1) }
  it { expect(offence.title).to eq('Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility') }
  it { expect(offence.mode_of_trial).to eq('Indictable-Only Offence') }
  it { expect(offence.maat_reference).to be_nil }
  it { expect(offence.plea).to be_nil }
  it { expect(offence.plea_date).to be_nil }

  context 'with an LAA reference' do
    let(:laa_reference) do
      {
        'laaApplnReference' => {
          'applicationReference' => 'AB746921',
          'statusId' => 'f644b843-a0a9-4344-81c5-ec484805775c',
          'statusCode' => 'GR',
          'statusDescription' => 'FAKE NEWS',
          'statusDate' => '1980-07-15'
        }
      }
    end

    subject(:offence) { described_class.new(body: offence_hash.merge(laa_reference)) }

    it { expect(offence.maat_reference).to eq('AB746921') }
  end

  context 'when details are available' do
    let(:details_hash) do
      {
        'plea' => {
          'pleaDate' => '2020-04-24',
          'pleaValue' => 'GUILTY'
        }
      }
    end

    it { expect(offence.plea).to eq('GUILTY') }
    it { expect(offence.plea_date).to eq('2020-04-24') }
  end
end
