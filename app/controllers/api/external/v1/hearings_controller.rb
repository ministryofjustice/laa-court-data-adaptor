# frozen_string_literal: true

module Api
  module External
    module V1
      class HearingsController < ApplicationController
        def create
          enforce_contract!

          HearingRecorder.call(
            hearing_id: params[:hearing][:id],
            hearing_resulted_data: transformed_params,
            publish_to_queue: true,
          )

          head :accepted
        end

      private

        def enforce_contract!
          unless contract.success?
            message = "Hearing contract failed with: #{contract.errors.to_hash}"
            raise Errors::ContractError, message
          end
        end

        def contract
          HearingContract.new.call(**transformed_params)
        end

        # Only allow a trusted parameter "white list" through.
        def hearing_params
          params.require(%i[sharedTime hearing])
          params.permit(:sharedTime, hearing: {})
        end

        def transformed_params
          hearing_params.to_hash.deep_symbolize_keys.compact
        end
      end
    end
  end
end
