# frozen_string_literal: true

RSpec.describe Normaliser::MlraProsecutionCaseSearch do
  let(:incoming_params) do
    ActionController::Parameters.new(
      prosecutionCases: {
        lastName: 'Doe',
        firstName: 'John',
        dob: '2012-10-15',
        nextHearingDate: '2021-01-01',
        caseReference: 'SOME CASE REFERENCE',
        asn: 'MG25A12456',
        nino: 'BN102966C'
      }
    )
  end

  let(:normalised_params) do
    ActionController::Parameters.new(
      prosecution_case_search: {
        name: {
          first_name: 'John',
          last_name: 'Doe'
        },
        date_of_birth: '2012-10-15',
        date_of_next_hearing: '2021-01-01',
        prosecution_case_reference: 'SOME CASE REFERENCE',
        arrest_summons_number: 'MG25A12456',
        national_insurance_number: 'BN102966C'
      }
    )
  end

  subject { described_class.call(incoming_params) }

  it 'normalises the params' do
    expect(subject).to eq(normalised_params)
  end
end
