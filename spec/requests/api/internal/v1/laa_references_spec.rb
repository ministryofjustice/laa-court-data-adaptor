# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/internal/v1/laa_references', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:mock_laa_reference_updater_job) { double LaaReferenceCreatorJob }
  let(:laa_reference) do
    {
      data: {
        type: 'laa_references',
        attributes: {
          maat_reference: 1_231_231
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
    allow(LaaReferenceCreatorJob).to receive(:new).and_return(mock_laa_reference_updater_job)
    allow(mock_laa_reference_updater_job).to receive(:enqueue)
  end

  path '/api/internal/v1/laa_references' do
    post('post laa_reference') do
      description 'Post an LAA reference to CDA to link a MAAT case to a Common Platform case'
      consumes 'application/json'
      tags 'Internal - available to other LAA applications'
      security [oAuth: []]

      response(202, 'Accepted') do
        around do |example|
          VCR.use_cassette('laa_reference_recorder/update') do
            example.run
          end
        end

        parameter name: :laa_reference, in: :body, required: false, type: :object,
                  schema: {
                    '$ref': 'laa_reference.json#/definitions/new_resource'
                  },
                  description: 'The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings'

        let(:Authorization) { "Bearer #{token.token}" }

        run_test!
      end

      context 'with a blank maat_reference' do
        response('202', 'Accepted') do
          before { laa_reference[:data][:attributes].delete(:maat_reference) }
          let(:Authorization) { "Bearer #{token.token}" }

          run_test!
        end
      end

      context 'with an invalid maat_reference' do
        response('400', 'Bad Request') do
          let(:Authorization) { "Bearer #{token.token}" }
          before { laa_reference[:data][:attributes][:maat_reference] = 'ABC123123' }

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
