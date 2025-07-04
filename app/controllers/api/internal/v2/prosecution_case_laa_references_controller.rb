# frozen_string_literal: true

module Api
  module Internal
    module V2
      class ProsecutionCaseLaaReferencesController < ApplicationController
        # Link the Defendant to court data
        def create
          contract = ProsecutionCaseLaaReferenceContract.new.call(**transformed_params)
          enforce_contract!(contract)

          ProsecutionCaseMaatLinkCreator.call(
            transformed_params[:defendant_id],
            transformed_params[:user_name],
            transformed_params[:maat_reference],
          )

          head :created
        end

        def update
          contract = UnlinkDefendantContract.new.call(**transformed_params)
          enforce_contract!(contract)

          unlink_defendant!

          head :ok
        end

      private

        def enforce_contract!(contract)
          unless contract.success?
            raise Errors::ContractError.new(contract, "Contract")
          end
        end

        def unlink_defendant!
          defendant_id = transformed_params[:defendant_id]
          LaaReference.find_by!(defendant_id:)

          ProsecutionCaseLaaReferenceUnlinker.call(**transformed_params)
        rescue ActiveRecord::RecordNotFound
          raise ActiveRecord::RecordNotFound, "Defendant with id = '#{defendant_id}' not found!"
        end

        def transformed_params
          create_params.slice(*allowed_params).to_hash.symbolize_keys.compact
        end

        def create_params
          params.require(:laa_reference).permit(allowed_params)
        end

        def allowed_params
          %i[
            maat_reference
            defendant_id
            user_name
            unlink_reason_code
            unlink_other_reason_text
          ]
        end
      end
    end
  end
end
