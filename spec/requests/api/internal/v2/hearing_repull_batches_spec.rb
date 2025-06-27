# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/hearing_repull_batches", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  describe "create" do
    path "/api/internal/v2/hearing_repull_batches" do
      post("create a repull batch") do
        description "set up an async batch job to repull MAAT IDs"
        consumes "application/json"
        tags "Internal - available to other LAA applications"
        security [{ oAuth: [] }]

        produces "application/vnd.api+json"
        parameter name: :maat_ids, in: :body, required: true, type: :string,
                  description: "A comma- or linebreak-separated list of MAAT IDs"

        before do
          defendant_id_1 = SecureRandom.uuid
          defendant_id_2 = SecureRandom.uuid
          defendant_id_3 = SecureRandom.uuid
          LaaReference.create!(linked: true, defendant_id: defendant_id_1, user_name: "123", maat_reference: "1111111")
          LaaReference.create!(linked: true, defendant_id: defendant_id_2, user_name: "123", maat_reference: "2222222")
          LaaReference.create!(linked: true, defendant_id: defendant_id_3, user_name: "123", maat_reference: "3333333")
          p_case = ProsecutionCase.create!(body: "foo")
          [defendant_id_1, defendant_id_2, defendant_id_3].each do |defendant_id|
            ProsecutionCaseDefendantOffence.create! prosecution_case: p_case, defendant_id:, offence_id: SecureRandom.uuid
          end

          post "/api/internal/v2/hearing_repull_batches",
               headers: { "Authorization" => "Bearer #{token.token}" },
               params: { maat_ids: "1111111, 2222222, 3333333" }
        end

        response(201, "Created") do
          it "returns 201 created message" do
            expect(response).to have_http_status(:created)
          end

          it "returns an ID" do
            expect(response.parsed_body["id"]).to be_present
          end

          it "persists a batch" do
            expect(HearingRepullBatch.find_by(id: response.parsed_body["id"])).not_to be_nil
          end

          it "persists the individual repulls" do
            expect(ProsecutionCaseHearingRepull.count).to eq 1
          end
        end
      end
    end
  end

  describe "show" do
    path "/api/internal/v2/hearing_repull_batches/:id" do
      get("shows a repull batch") do
        description "Retrieve a repull batch and the current status of all its repulls"
        consumes "application/json"
        tags "Internal - available to other LAA applications"
        security [{ oAuth: [] }]

        produces "application/vnd.api+json"

        before do
          batch = HearingRepullBatch.create!
          prosecution_case = ProsecutionCase.create!(body: "foo")
          ProsecutionCaseHearingRepull.create!(prosecution_case:, hearing_repull_batch: batch, status: "error")
          get "/api/internal/v2/hearing_repull_batches/#{batch.id}",
              headers: { "Authorization" => "Bearer #{token.token}" }
        end

        response(200, "OK") do
          it "returns 200 created message" do
            expect(response).to have_http_status(:ok)
          end

          it "returns an ID" do
            expect(response.parsed_body["id"]).to be_present
          end

          it "shows whether the batch is completed" do
            expect(response.parsed_body["complete"]).to be false
          end

          it "shows individual repulls" do
            expect(response.parsed_body["repulls"][0]["status"]).to eq "error"
          end
        end
      end
    end
  end
end
