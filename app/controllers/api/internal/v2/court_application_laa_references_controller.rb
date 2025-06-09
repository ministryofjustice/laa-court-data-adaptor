module Api
  module Internal
    module V2
      class CourtApplicationLaaReferencesController < ApplicationController
        def create
          contract = CourtApplicationLaaReferenceContract.new.call(**transformed_params)
          enforce_contract!(contract)

          enqueue_link
          head :accepted
        end

        def update
          contract = UnlinkCourtApplicationSubjectContract.new.call(**transformed_params)
          enforce_contract!(contract)

          enqueue_unlink
          head :accepted
        end

      private

        def enforce_contract!(contract)
          unless contract.success?
            raise Errors::ContractError.new(contract, "Contract")
          end
        end

        def enqueue_link
          CourtApplicationMaatLinkCreatorWorker.perform_async(
            Current.request_id,
            transformed_params[:subject_id],
            transformed_params[:user_name],
            transformed_params[:maat_reference],
          )
        end

        def enqueue_unlink
          check_defendant_presence!

          UnlinkCourtApplicationLaaReferenceWorker.perform_async(
            Current.request_id,
            transformed_params[:subject_id],
            transformed_params[:user_name],
            transformed_params[:unlink_reason_code],
            transformed_params[:unlink_other_reason_text],
            transformed_params[:maat_reference],
          )
        end

        def check_defendant_presence!
          LaaReference.find_by!(defendant_id: transformed_params[:subject_id])
        end

        def transformed_params
          laa_reference_params.slice(*allowed_params).to_hash.symbolize_keys.compact
        end

        def laa_reference_params
          params.require(:laa_reference).permit(allowed_params)
        end

        def allowed_params
          %i[
            maat_reference
            subject_id
            user_name
            unlink_reason_code
            unlink_other_reason_text
          ]
        end
      end
    end
  end
end
