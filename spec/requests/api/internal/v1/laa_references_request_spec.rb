# frozen_string_literal: true

RSpec.describe 'Api::Internal::V1::LaaReferences', type: :request do
  include AuthorisedRequestHelper

  let(:valid_body) do
    {
      data: {
        type: 'laa_references',
        attributes: {
          maat_reference: maat_reference
        },
        relationships: {
          defendant: {
            data: {
              type: 'defendants',
              id: 'db1cc378-a0e9-4943-bc36-7b34e47ae943'
            }
          }
        }
      }
    }
  end
  let(:fragment) { '#/definitions/laa_reference/definitions/new_resource' }
  let(:maat_reference) { 1_231_231 }

  describe 'POST /api/internal/v1/laa_references' do
    let(:headers) { valid_auth_header }

    it 'matches the given schema' do
      expect(valid_body).to be_valid_against_schema(fragment: fragment)
    end

    it 'returns an accepted status' do
      post api_internal_v1_laa_references_path, params: valid_body, headers: valid_auth_header
      expect(response).to have_http_status(202)
    end

    context 'with an invalid maat_reference' do
      let(:maat_reference) { 'ABC123123' }

      it 'returns a bad_request status' do
        post api_internal_v1_laa_references_path, params: valid_body, headers: valid_auth_header
        expect(response).to have_http_status(400)
      end
    end

    context 'with a blank maat_reference' do
      before { valid_body[:data][:attributes].delete(:maat_reference) }

      it 'returns an accepted status' do
        post api_internal_v1_laa_references_path, params: valid_body, headers: valid_auth_header
        expect(response).to have_http_status(202)
      end
    end
  end
end
