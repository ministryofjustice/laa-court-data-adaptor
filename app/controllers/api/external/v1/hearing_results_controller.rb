# frozen_string_literal: true

module Api
  module External
    module V1
      class HearingResultsController < ApplicationController
        def create
          enforce_contract!
          publish_hearing_to_queue

          head :accepted
        end

      private

        def enforce_contract!
          unless contract.success?
            raise Errors::ContractError.new(contract, "Hearing contract")
          end
        end

        def contract
          HearingContract.new.call(**transformed_params)
        end

        def hearing_params
          params.require(%i[sharedTime hearing])
          params.permit(:sharedTime, hearing: {})
        end

        def transformed_params
          hearing_params.to_hash.deep_symbolize_keys.compact
        end

        def publish_hearing_to_queue
          HearingsCreatorWorker.perform_async(
            Current.request_id,
            transformed_params.deep_stringify_keys,
          )
        end
      end
    end
  end
end
