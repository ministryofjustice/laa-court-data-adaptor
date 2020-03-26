# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Internal::V1::Defendants', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }

  path '/api/internal/v1/defendants/{defendant_id}/relationships/laa_references' do
    delete('delete defendant relationships') do
      description 'Delete an LAA reference from Common Platform case'
      consumes 'application/json'
      tags 'Internal - available to other LAA applications'
      security [oAuth: []]

      response(202, 'Accepted') do
        around do |example|
          VCR.use_cassette('laa_reference_recorder/update') do
            example.run
          end
        end

        parameter name: :defendant_id, in: :path, required: true, type: :object,
                  schema: {
                    '$ref': 'defendant.json#/definitions/id'
                  },
                  description: 'The unique identifier of the defendant'

        let(:Authorization) { "Bearer #{token.token}" }

        run_test!
      end

      context 'Bad data' do
        response('400', 'Bad Request') do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:defendant_id) { 'X' }

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
