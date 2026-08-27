# frozen_string_literal: true

module Api
  module Internal
    module V2
      class LinkMigratedCasesController < ApplicationController
        before_action :set_migrated_case,
                      :set_contract,
                      :enforce_contract!, only: %i[create]

        # POST /api/internal/v2/link_migrated_cases
        def create
          resolve_link_creator_class.call(
            transformed_params[:defendant_id],
            transformed_params[:user_name],
            transformed_params[:maat_reference],
          )

          head :created
        end

      private

        def set_migrated_case
          @migrated_case = XhibitMigratedCase.find(transformed_params[:id])
        end

        def set_contract
          @contract = if @migrated_case.trial?
                        ProsecutionCaseLaaReferenceContract.new.call(**transformed_params)
                      else
                        CourtApplicationLaaReferenceContract.new.call(**transformed_params.except(:defendant_id).merge(subject_id: transformed_params[:defendant_id]))
                      end
        end

        def enforce_contract!
          unless @contract.success?
            raise Errors::ContractError.new(@contract, "Contract")
          end
        end

        def resolve_link_creator_class
          @migrated_case.trial? ? ProsecutionCaseMaatLinkCreator : CourtApplicationMaatLinkCreator
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
            id
          ]
        end
      end
    end
  end
end
