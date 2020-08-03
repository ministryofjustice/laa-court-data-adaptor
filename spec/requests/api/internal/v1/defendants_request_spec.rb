# frozen_string_literal: true

require 'swagger_helper'
require 'sidekiq/testing'

RSpec.describe 'Api::Internal::V1::Defendants', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:include) {}
  let(:defendant) do
    {
      data: {
        type: 'defendants',
        attributes: {
          user_name: 'johnDoe',
          unlink_reason_code: 1,
          unlink_other_reason_text: ''
        }
      }
    }
  end

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  path '/api/internal/v1/defendants/{id}' do
    patch('patch defendant relationships') do
      description 'Delete an LAA reference from Common Platform case'
      consumes 'application/json'
      tags 'Internal - available to other LAA applications'
      security [oAuth: []]

      response(202, 'Accepted') do
        parameter name: :id, in: :path, required: true, type: :uuid,
                  schema: {
                    '$ref': 'defendant.json#/definitions/id'
                  },
                  description: 'The unique identifier of the defendant'

        parameter name: :defendant, in: :body, required: true, type: :object,
                  schema: {
                    '$ref': 'defendant.json#/definitions/resource_to_unlink'
                  },
                  description: 'Object containing the user_name, unlink_reason_code and unlink_other_reason_text'

        parameter '$ref' => '#/components/parameters/transaction_id_header'

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(UnlinkLaaReferenceWorker).to receive(:perform_async).with(String, id, 'johnDoe', 1, '').and_call_original
        end

        run_test!
      end

      context 'Bad data' do
        response('400', 'Bad Request') do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:id) { 'X' }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          before do
            expect(UnlinkLaaReferenceWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context 'unauthorized request' do
        response('401', 'Unauthorized') do
          let(:Authorization) { nil }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          before do
            expect(UnlinkLaaReferenceWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end
    end

    get('fetch a defendant by ID') do
      description 'find a defendant where it exists within Court Data Adaptor'
      consumes 'application/json'
      tags 'Internal - available to other LAA applications'
      security [oAuth: []]

      parameter name: :id, in: :path, required: true, type: :uuid,
                schema: {
                  '$ref': 'defendant.json#/definitions/id'
                },
                description: 'The uuid of the defendant'

      parameter name: 'include', in: :query, required: false, type: :string,
                schema: {},
                description: 'Return other data through a has_many relationship </br>e.g. include=offences'

      context 'with success' do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:id) { 'c6cf04b5-901d-4a89-a9ab-767eb57306e4' }
        let!(:prosecution_case_result) do
          VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
            Api::SearchProsecutionCase.call(prosecution_case_reference: '19GD1001816')
          end
        end

        context 'with no inclusions' do
          let(:include) {}

          response(200, 'Success') do
            run_test!
          end
        end

        context 'with offences included' do
          let(:include) { 'offences' }

          response(200, 'Success') do
            run_test! do |response|
              hashed = JSON.parse(response.body, symbolize_names: true)
              included_types = hashed[:included].map { |inc| inc[:type] }
              expect(included_types).to all(eql('offences'))
            end
          end
        end
      end

      context 'when not found' do
        response('404', 'Not found') do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:id) { 'c6cf04b5' }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          run_test!
        end
      end
    end
  end
end
