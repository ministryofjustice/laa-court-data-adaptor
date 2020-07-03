# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/external/v1/hearings', type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  path '/api/external/v1/hearings' do
    post('post hearing') do
      description 'Post Common Platform hearing data to CDA'
      consumes 'application/json'
      tags 'External - available to Common Platform'
      security [oAuth: []]

      response(202, 'Accepted') do
        parameter name: :hearing, in: :body, required: false, type: :object,
                  schema: {
                    '$ref': 'hearing_resulted.json#/definitions/new_resource'
                  },
                  description: 'The minimal Hearing Resulted payload'

        let(:Authorization) { "Bearer #{token.token}" }
        let(:hearing) { JSON.parse(file_fixture('valid_hearing.json').read) }

        before do
          expect(HearingsCreatorWorker).to receive(:perform_async)
        end

        run_test!
      end

      context 'unprocessable entity' do
        response('422', 'Unprocessable Entity') do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:hearing) { JSON.parse(file_fixture('unprocessable_hearing.json').read) }

          run_test!
        end
      end

      context 'invalid data' do
        response('400', 'Bad Request') do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:hearing) { JSON.parse(file_fixture('invalid_hearing.json').read) }

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
