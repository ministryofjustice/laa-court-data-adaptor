# frozen_string_literal: true

module Api
  module Internal
    module V1
      class DefendantsController < ApplicationController
        def destroy_laa_references
          contract = UnlinkDefendantContract.new.call(**transformed_params)
          if contract.success?
            UnlinkLaaReferenceJob.perform_later(**transformed_params)
            render status: :accepted
          else
            render json: contract.errors.to_hash, status: :bad_request
          end
        end

        private

        def transformed_params
          params.permit(:defendant_id).to_hash.transform_keys(&:to_sym).compact
        end
      end
    end
  end
end
