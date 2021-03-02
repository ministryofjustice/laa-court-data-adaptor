# frozen_string_literal: true

module Api
  module Internal
    module V1
      class LaaReferencesController < ApplicationController
        def create
          if contract.success?
            create_laa_reference
            render status: :accepted
          else
            render json: contract.errors.to_hash, status: :bad_request
          end
        end

      private

        def contract
          @contract ||= NewLaaReferenceContract.new.call(**transformed_params)
        end

        def create_laa_reference
          LaaReferenceCreator.call(defendant_id: transformed_params[:defendant_id],
                                   user_name: transformed_params[:user_name],
                                   maat_reference: transformed_params[:maat_reference])
        end

        def create_params
          params.from_jsonapi.require(:laa_reference).permit(allowed_params)
        end

        def allowed_params
          %i[maat_reference defendant_id user_name]
        end

        def transformed_params
          create_params.slice(*allowed_params).to_hash.transform_keys(&:to_sym).compact
        end
      end
    end
  end
end
