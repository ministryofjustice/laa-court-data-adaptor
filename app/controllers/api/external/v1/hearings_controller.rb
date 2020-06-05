# frozen_string_literal: true

module Api
  module External
    module V1
      class HearingsController < ApplicationController
        def create
          contract = HearingContract.new.call(**transformed_params)
          if contract.success?
            HearingRecorder.call(hearing_id: params[:hearing][:id], body: hearing_params)
            head :accepted
          else
            render json: contract.errors.to_hash, status: :unprocessable_entity
          end
        end

        private

        # Only allow a trusted parameter "white list" through.
        def hearing_params
          params.require(%i[sharedTime hearing])
          params.permit(:sharedTime, hearing: {})
        end

        def transformed_params
          hearing_params.to_hash.deep_transform_keys(&:to_sym).compact
        end
      end
    end
  end
end
