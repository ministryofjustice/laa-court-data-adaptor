# frozen_string_literal: true

module Api
  module Internal
    module V1
      class ProsecutionCaseLaaReferencesController < ApplicationController
        def create
          contract = ProsecutionCaseLaaReferenceContract.new.call(**transformed_params)
          enforce_contract!(contract)

          ProsecutionCaseMaatLinkCreatorWorker.perform_async(
            Current.request_id,
            transformed_params[:defendant_id],
            transformed_params[:user_name],
            transformed_params[:maat_reference],
          )

          head :accepted
        end

      private

        def enforce_contract!(contract)
          unless contract.success?
            raise Errors::ContractError.new(contract, "Contract")
          end
        end

        def transformed_params
          create_params.slice(*allowed_params).to_hash.symbolize_keys.compact
        end

        def create_params
          params.from_jsonapi.require(:laa_reference).permit(allowed_params)
        end

        def allowed_params
          %i[
            maat_reference
            defendant_id
            user_name
          ]
        end
      end
    end
  end
end
