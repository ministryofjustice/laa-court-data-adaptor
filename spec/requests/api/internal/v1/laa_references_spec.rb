# frozen_string_literal: true

require 'swagger_helper'
require 'sidekiq/testing'

RSpec.describe 'api/internal/v1/laa_references', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:laa_reference) do
    {
      data: {
        type: 'laa_references',
        attributes: {
          maat_reference: 1_231_231,
          user_name: 'JaneDoe'
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

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  path '/api/internal/v1/laa_references' do
    post('post laa_reference') do
      description 'Post an LAA reference to CDA to link a MAAT case to a Common Platform case'
      consumes 'application/json'
      tags 'Internal - available to other LAA applications'
      security [oAuth: []]

      response(202, 'Accepted') do
        around do |example|
          Sidekiq::Testing.fake!
          VCR.use_cassette('laa_reference_recorder/update') do
            example.run
          end
        end

        parameter name: :laa_reference, in: :body, required: false, type: :object,
                  schema: {
                    '$ref': 'laa_reference.json#/definitions/new_resource'
                  },
                  description: 'The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings'

        parameter '$ref' => '#/components/parameters/transaction_id_header'

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(LaaReferenceCreatorWorker).to receive(:perform_async).with(String, String, 'JaneDoe', 1_231_231).and_call_original
        end

        run_test!
      end

      context 'with a blank maat_reference' do
        response(202, 'Accepted') do
          before { laa_reference[:data][:attributes].delete(:maat_reference) }
          let(:Authorization) { "Bearer #{token.token}" }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          before do
            expect(LaaReferenceCreatorWorker).to receive(:perform_async).with(String, String, 'JaneDoe', nil).and_call_original
          end

          run_test!
        end
      end

      context 'with a blank user_name' do
        response(202, 'Accepted') do
          before { laa_reference[:data][:attributes].delete(:user_name) }
          let(:Authorization) { "Bearer #{token.token}" }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          before do
            expect(LaaReferenceCreatorWorker).to receive(:perform_async).with(String, String, nil, 1_231_231).and_call_original
          end

          run_test!
        end
      end

      context 'with an invalid maat_reference' do
        response('400', 'Bad Request') do
          let(:Authorization) { "Bearer #{token.token}" }
          before { laa_reference[:data][:attributes][:maat_reference] = 'ABC123123' }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          before do
            expect(LaaReferenceCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context 'unauthorized request' do
        response('401', 'Unauthorized') do
          let(:Authorization) { nil }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          before do
            expect(LaaReferenceCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end
    end
  end
end
