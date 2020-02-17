# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/internal/v1/prosecution_cases', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:schema) { File.read('schema/schema.json') }

  path '/api/internal/v1/prosecution_cases' do
    get('list prosecution_cases') do
      description 'Search prosecution cases'
      consumes 'application/json'
      security [oauth: ['read']]

      context 'search by prosecution_case_reference' do
        response(200, 'Success') do
          around do |example|
            VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
              example.run
            end
          end

          parameter name: 'filter[prosecution_case_reference]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'prosecution_case.json#/definitions/prosecution_case_reference'
                    },
                    description: 'Searches prosecution cases by prosecution case reference'

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[prosecution_case_reference]') { 'TFL12345' }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context 'search by arrest_summons_number' do
        response(200, 'Success') do
          around do |example|
            VCR.use_cassette('search_prosecution_case/by_arrest_summons_number_success') do
              example.run
            end
          end

          parameter name: 'filter[arrest_summons_number]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'prosecution_case.json#/definitions/arrest_summons_number'
                    },
                    description: 'Searches prosecution cases by arrest summons number'

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[arrest_summons_number]') { 'arrest123' }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context 'search by national_insurance_number' do
        response(200, 'Success') do
          around do |example|
            VCR.use_cassette('search_prosecution_case/by_national_insurance_number_success') do
              example.run
            end
          end

          parameter name: 'filter[national_insurance_number]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'defendant.json#/definitions/nino'
                    },
                    description: 'Searches prosecution cases by national_insurance_number'

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[national_insurance_number]') { 'BN102966C' }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context 'search by name and date of birth' do
        response(200, 'Success') do
          around do |example|
            VCR.use_cassette('search_prosecution_case/by_name_and_date_of_birth_success') do
              example.run
            end
          end

          parameter name: 'filter[first_name]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'defendant.json#/definitions/first_name'
                    },
                    description: 'Searches prosecution cases by first_name'

          parameter name: 'filter[last_name]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'defendant.json#/definitions/last_name'
                    },
                    description: 'Searches prosecution cases by last_name'

          parameter name: 'filter[date_of_birth]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'defendant.json#/definitions/date_of_birth'
                    },
                    description: 'Searches prosecution cases by date_of_birth'

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[first_name]') { 'Alfredine' }
          let(:'filter[last_name]') { 'Parker' }
          let(:'filter[date_of_birth]') { '1971-05-12' }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
        end
      end

      context 'search by name and date of next hearing' do
        response(200, 'Success') do
          around do |example|
            VCR.use_cassette('search_prosecution_case/by_name_and_date_of_next_hearing_success') do
              example.run
            end
          end

          parameter name: 'filter[first_name]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'defendant.json#/definitions/first_name'
                    },
                    description: 'Searches prosecution cases by first_name'

          parameter name: 'filter[last_name]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'defendant.json#/definitions/last_name'
                    },
                    description: 'Searches prosecution cases by last_name'

          parameter name: 'filter[date_of_next_hearing]', in: :query, required: false, type: :string,
                    schema: {
                      '$ref': 'prosecution_case.json#/definitions/date_of_next_hearing'
                    },
                    description: 'Searches prosecution cases by date_of_next_hearing'

          let(:Authorization) { "Bearer #{token.token}" }
          let(:'filter[first_name]') { 'Alfredine' }
          let(:'filter[last_name]') { 'Parker' }
          let(:'filter[date_of_next_hearing]') { '2025-05-04' }

          run_test! do |response|
            expect(response.body).to be_valid_against_schema(schema: schema)
          end
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
