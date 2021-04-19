# frozen_string_literal: true

module Api
  module Internal
    module V2
      class LaaReferencesController < ApplicationController
        def create
          contract = NewLaaReferenceContract.new.call(**transformed_params)
          enforce_contract!(contract)

          LaaReferenceCreator.call(defendant_id: transformed_params[:defendant_id],
                                   user_name: transformed_params[:user_name],
                                   maat_reference: transformed_params[:maat_reference])

          render status: :accepted
        end

        def destroy
          contract = UnlinkDefendantContract.new.call(**transformed_params)
          enforce_contract!(contract)

          UnlinkLaaReferenceWorker.perform_async(
            Current.request_id,
            transformed_params[:defendant_id],
            transformed_params[:user_name],
            transformed_params[:unlink_reason_code],
            transformed_params[:unlink_other_reason_text],
          )

          render status: :accepted
        end

      private

        def enforce_contract!(contract)
          unless contract.success?
            message = "Contract failed with: #{contract.errors.to_hash}"
            raise Errors::ContractError, message
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
            unlink_reason_code
            unlink_other_reason_text
          ]
        end
      end
    end
  end
end
