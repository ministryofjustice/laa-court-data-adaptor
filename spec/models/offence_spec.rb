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

  subject(:offence) { described_class.new(body: offence_hash) }

  it { expect(offence.code).to eq('AA06001') }
  it { expect(offence.order_index).to eq(1) }
  it { expect(offence.title).to eq('Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility') }
  it { expect(offence.mode_of_trial).to eq('Indictable-Only Offence') }
end
