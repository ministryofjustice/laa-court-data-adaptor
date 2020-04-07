# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/internal/v1/representation_orders', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:mock_rep_order_creator_job) { double RepresentationOrderCreatorJob }
  let(:defence_organisation) do
    {
      laa_contract_number: 'CONTRACT REFERENCE',
      sra_number: 'SRA NUMBER',
      bar_council_membership_number: 'BAR COUNCIL NUMBER',
      incorporation_number: 'AAA',
      registered_charity_number: 'BBB',
      organisation: {
        name: 'SOME ORGANISATION',
        address: {
          address1: '102',
          address2: 'Petty France',
          address3: 'Floor 5',
          address4: 'St James',
          address5: 'Westminster',
          postcode: 'EC4A 2AH'
        },
        contact: {
          home: '+99999',
          work: 'CALL ME 888',
          mobile: '+99999',
          primary_email: 'a@example.com',
          secondary_email: 'a@example.com',
          fax: 'ABC123123'
        }
      }
    }
  end
  let(:representation_order) do
    {
      data: {
        type: 'representation_orders',
        attributes: {
          maat_reference: 1_231_231,
          defence_organisation: defence_organisation,
          offences: [
            {
              offence_id: SecureRandom.uuid,
              status_code: 'GR',
              status_date: Date.new(2020, 2, 12),
              effective_start_date: Date.new(2020, 2, 20),
              effective_end_date: Date.new(2020, 2, 25)
            }
          ]
        },
        relationships: {
          defendant: {
            data: {
              type: 'defendants',
              id: SecureRandom.uuid
            }
          }
        }
      }
    }
  end

  before do
    allow(RepresentationOrderCreatorJob).to receive(:new).and_return(mock_rep_order_creator_job)
    allow(mock_rep_order_creator_job).to receive(:enqueue)
  end

  path '/api/internal/v1/representation_orders' do
    post('post representation_order') do
      description 'Post a Representation Order to CDA to update the status on a MAAT case to a Common Platform case'
      consumes 'application/vnd.api+json'
      tags 'Internal - available to other LAA applications'
      security [oAuth: []]

      response(202, 'Accepted') do
        around do |example|
          VCR.use_cassette('representation_order_recorder/update') do
            example.run
          end
        end

        parameter name: :representation_order, in: :body, required: true, type: :object,
                  schema: {
                    '$ref': 'representation_order.json#/definitions/new_resource'
                  },
                  description: 'The Representation Order for an offence'

        let(:Authorization) { "Bearer #{token.token}" }

        run_test!
      end

      context 'with an invalid maat_reference' do
        response('400', 'Bad Request') do
          let(:Authorization) { "Bearer #{token.token}" }
          before { representation_order[:data][:attributes][:maat_reference] = 'ABC123123' }

          run_test!
        end
      end

      context 'unauthorized request' do
        response('401', 'Unauthorized') do
          let(:Authorization) { nil }

          run_test!
        end
      end
    end
  end
end
