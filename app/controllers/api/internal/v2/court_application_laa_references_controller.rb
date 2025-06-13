module Api
  module Internal
    module V2
      class CourtApplicationLaaReferencesController < ApplicationController
        def create
          contract = CourtApplicationLaaReferenceContract.new.call(**transformed_params)
          enforce_contract!(contract)

          link
          head :created
        end

        def update
          contract = UnlinkCourtApplicationSubjectContract.new.call(**transformed_params)
          enforce_contract!(contract)

          unlink
          head :ok
        end

      private

        def enforce_contract!(contract)
          unless contract.success?
            raise Errors::ContractError.new(contract, "Contract")
          end
        end

        def link
          CourtApplicationMaatLinkCreator.call(
            transformed_params[:subject_id],
            transformed_params[:user_name],
            transformed_params[:maat_reference],
          )
        end

        def unlink
          check_defendant_presence!

          CourtApplicationLaaReferenceUnlinker.call(**transformed_params)
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
