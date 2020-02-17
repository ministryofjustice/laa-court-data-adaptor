# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Offence, type: :model do
  let(:offence_hash) do
    {
      'offenceCodeorderIndex' => 'AA06001',
      'orderIndex' => '0',
      'offenceTitle' => 'Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility',
      'offenceLegislation' => 'N/A',
      'wording' => 'Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility',
      'arrestDate' => '2020-02-01',
      'chargeDate' => '2020-02-01',
      'dateOfInformation' => '2020-02-01',
      'modeOfTrial' => 'Indictable-Only Offence',
      'startDate' => '2020-02-01',
      'endDate' => nil,
      'proceedingConcluded' => 'N',
      'laaApplnReference' => {
        'applicationReference' => '1234567',
        'statusId' => '0',
        'statusCode' => 'AP',
        'statusDescription' => 'Application Pending',
        'statusDate' => '2020-02-01',
        'effectiveStartDate' => '2020-02-01',
        'effectiveEndDate' => nil
      }
    }
  end

  subject(:offence) { described_class.new(body: offence_hash) }

  it { expect(offence.offence_code_order_index).to eq('AA06001') }
  it { expect(offence.order_index).to eq('0') }
  it { expect(offence.offence_title).to eq('Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility') }
  it { expect(offence.offence_legislation).to eq('N/A') }
  it { expect(offence.wording).to eq('Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility') }
  it { expect(offence.arrest_date).to eq('2020-02-01') }
  it { expect(offence.charge_date).to eq('2020-02-01') }
  it { expect(offence.date_of_information).to eq('2020-02-01') }
  it { expect(offence.mode_of_trial).to eq('Indictable-Only Offence') }
  it { expect(offence.start_date).to eq('2020-02-01') }
  it { expect(offence.end_date).to be_nil }
  it { expect(offence.proceeding_concluded).to eq('N') }
  it { expect(offence.application_reference).to eq('1234567') }
  it { expect(offence.status_id).to eq('0') }
  it { expect(offence.status_code).to eq('AP') }
  it { expect(offence.status_description).to eq('Application Pending') }
  it { expect(offence.status_date).to eq('2020-02-01') }
  it { expect(offence.effective_start_date).to eq('2020-02-01') }
  it { expect(offence.effective_end_date).to be_nil }
end
