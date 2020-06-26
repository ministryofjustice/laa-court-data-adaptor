# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Internal::V1::Hearings', type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  let(:id) { 'ee7b9c09-4a6e-49e3-a484-193dc93a4575' }

  path '/api/internal/v1/hearings/{id}' do
    get('get hearing') do
      description 'GET Common Platform hearing data'
      consumes 'application/json'
      tags 'Internal - available to other LAA applications'
      security [oAuth: []]

      response(200, 'Success') do
        around do |example|
          VCR.use_cassette('hearing_result_fetcher/success') do
            VCR.use_cassette('hearing_logs_fetcher/success') do
              example.run
            end
          end
        end

        parameter name: :id, in: :path, required: true, type: :uuid,
                  schema: {
                    '$ref': 'hearing.json#/definitions/id'
                  },
                  description: 'The unique identifier of the hearing'

        parameter '$ref' => '#/components/parameters/transaction_id_header'

        let(:Authorization) { "Bearer #{token.token}" }
        let(:shared_time) { JSON.parse(file_fixture('valid_hearing.json').read) }

        run_test!
      end

      context 'unauthorized request' do
        response('401', 'Unauthorized') do
          around do |example|
            VCR.use_cassette('hearing_result_fetcher/unauthorised') do
              example.run
            end
          end

          let(:Authorization) { nil }

          parameter '$ref' => '#/components/parameters/transaction_id_header'

          run_test!
        end
      end
    end
  end
end
