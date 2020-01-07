# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RecordRepresentationOrder do
  subject { described_class.call(params) }

  let(:prosecution_case_id) { 'b9950946-fe3b-4eaa-9f0a-35e497e34528' }
  let(:defence_organisation) do
    {
      organisation: {
        name: 'SOME ORGANISATION'
      },
      laaContractNumber: 'CONTRACT REFERENCE'
    }
  end

  let(:params) do
    {
      prosecution_case_id: prosecution_case_id,
      defendant_id: '23d7f10a-067a-476e-bba6-bb855674e23b',
      offence_id: '147fed98-ba8a-46cb-b2b4-7c41cf4734bf',
      status_code: 'ABCDEF',
      application_reference: 'SOME SORT OF MAAT ID',
      status_date: '2019-12-12',
      effective_start_date: '2019-12-15',
      defence_organisation: defence_organisation
    }
  end

  # rubocop:disable Layout/LineLength
  let(:api_request_url) { "/receive/representation-sit/progression-command-api/command/api/rest/progression/representationOrder/cases/#{prosecution_case_id}/defendants/23d7f10a-067a-476e-bba6-bb855674e23b/offences/147fed98-ba8a-46cb-b2b4-7c41cf4734bf" }
  # rubocop:enable Layout/LineLength

  it_has_a 'correct api request url'

  it 'returns an ok status' do
    VCR.use_cassette('representation_order_recorder/update') do
      expect(subject.status).to eq(200)
    end
  end
end
