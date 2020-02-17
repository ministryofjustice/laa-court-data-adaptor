# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OffenceSerializer do
  let(:offence) do
    instance_double('Offence',
                    id: 'UUID',
                    offence_code_order_index: 'AA06001',
                    order_index: '0',
                    offence_title: 'Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility',
                    offence_legislation: 'N/A',
                    wording: 'Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility',
                    arrest_date: '2020-02-01',
                    charge_date: '2020-02-01',
                    date_of_information: '2020-02-01',
                    mode_of_trial: 'Indictable-Only Offence',
                    start_date: '2020-02-01',
                    end_date: nil,
                    proceeding_concluded: 'N',
                    application_reference: '1234567',
                    status_id: '0',
                    status_code: 'AP',
                    status_description: 'Application Pending',
                    status_date: '2020-02-01',
                    effective_start_date: '2020-02-01',
                    effective_end_date: nil)
  end

  subject { described_class.new(offence).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:offence_code_order_index]).to eq('AA06001') }
    it { expect(attribute_hash[:order_index]).to eq('0') }
    it { expect(attribute_hash[:offence_title]).to eq('Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility') }
    it { expect(attribute_hash[:offence_legislation]).to eq('N/A') }
    it { expect(attribute_hash[:wording]).to eq('Fail to wear protective clothing / meet other criteria on entering quarantine centre/facility') }
    it { expect(attribute_hash[:arrest_date]).to eq('2020-02-01') }
    it { expect(attribute_hash[:charge_date]).to eq('2020-02-01') }
    it { expect(attribute_hash[:date_of_information]).to eq('2020-02-01') }
    it { expect(attribute_hash[:mode_of_trial]).to eq('Indictable-Only Offence') }
    it { expect(attribute_hash[:start_date]).to eq('2020-02-01') }
    it { expect(attribute_hash[:end_date]).to be_nil }
    it { expect(attribute_hash[:proceeding_concluded]).to eq('N') }
    it { expect(attribute_hash[:application_reference]).to eq('1234567') }
    it { expect(attribute_hash[:status_id]).to eq('0') }
    it { expect(attribute_hash[:status_code]).to eq('AP') }
    it { expect(attribute_hash[:status_description]).to eq('Application Pending') }
    it { expect(attribute_hash[:status_date]).to eq('2020-02-01') }
    it { expect(attribute_hash[:effective_start_date]).to eq('2020-02-01') }
    it { expect(attribute_hash[:effective_end_date]).to be_nil }
  end
end
