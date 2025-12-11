module Api
  module Internal
    module V2
      class CourtApplicationLaaReferencesController < ApplicationController
        # POST /api/internal/v2/court_application_laa_references
        def create
          contract = CourtApplicationLaaReferenceContract.new.call(**transformed_params)
          enforce_contract!(contract)

          CourtApplicationMaatLinkCreator.call(
            transformed_params[:subject_id],
            transformed_params[:user_name],
            transformed_params[:maat_reference],
          )

          head :created
        end

        # PUT /api/internal/v2/court_application_laa_references/:subject_id
        def update
          contract = UnlinkCourtApplicationSubjectContract.new.call(**transformed_params)
          enforce_contract!(contract)

          CourtApplicationLaaReferenceUnlinker.call(
            subject_id: transformed_params[:subject_id],
            user_name: transformed_params[:user_name],
            unlink_reason_code: transformed_params[:unlink_reason_code],
            unlink_other_reason_text: transformed_params[:unlink_other_reason_text],
            maat_reference: transformed_params[:maat_reference],
          )

          head :ok
        end

      private

        def enforce_contract!(contract)
          unless contract.success?
            raise Errors::ContractError.new(contract, "Contract")
          end
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
