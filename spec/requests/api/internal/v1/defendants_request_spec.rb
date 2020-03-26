# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Internal::V1::Defendants', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:defendant) do
    {
      data: {
        type: 'defendants',
        attributes: {
          user_name: 'johnDoe',
          unlink_reason_code: 1,
          unlink_reason_text: 'Wrong defendant'
        }
      }
    }
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
                  description: 'Object containing the user_name, unlink_reason_code and unlink_reason_text'

        let(:Authorization) { "Bearer #{token.token}" }

        run_test!
      end

      context 'Bad data' do
        response('400', 'Bad Request') do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:id) { 'X' }

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
