# frozen_string_literal: true

module Api
  module Internal
    module V1
      class LaaReferencesController < ApplicationController
        def create
          contract = LaaReferenceCreator.call(**transformed_params)
          if contract.errors.present?
            render json: contract.errors.to_hash, status: :bad_request
          else
            render status: :accepted
          end
        end

        private

        def create_params
          params.from_jsonapi.require(:laa_reference).permit(allowed_params)
        end

        def allowed_params
          %i[maat_reference defendant_id]
        end

        def transformed_params
          create_params.slice(*allowed_params).to_hash.transform_keys(&:to_sym)
        end
      end
    end
  end
end
