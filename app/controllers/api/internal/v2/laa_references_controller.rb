# frozen_string_literal: true

module Api
  module Internal
    module V2
      class LaaReferencesController < ApplicationController
        # Create link to court data
        def create
          contract = NewLaaReferenceContract.new.call(**transformed_params)
          enforce_contract!(contract)

          MaatLinkCreatorWorker.perform_async(
            Current.request_id,
            transformed_params[:defendant_id],
            transformed_params[:user_name],
            transformed_params[:maat_reference],
          )

          head :accepted
        end

        def update
          contract = UnlinkDefendantContract.new.call(**transformed_params)

          if contract.success?
            enqueue_unlink
            head :accepted
          else
            render json: contract.errors.to_hash, status: :bad_request
          end
        end

      private

        def enforce_contract!(contract)
          unless contract.success?
            raise Errors::ContractError.new(contract, "Contract")
          end
        end

        def enqueue_unlink
          check_defendant_presence!

          UnlinkLaaReferenceWorker.perform_async(
            Current.request_id,
            transformed_params[:defendant_id],
            transformed_params[:user_name],
            transformed_params[:unlink_reason_code],
            transformed_params[:unlink_other_reason_text],
            transformed_params[:maat_reference],
          )
        end

        def check_defendant_presence!
          laa_reference = LaaReference.find_by(defendant_id: transformed_params[:defendant_id])

          if laa_reference.nil?
            raise ActiveRecord::RecordNotFound, "Defendant not found!"
          end
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
