# frozen_string_literal: true

module Api
  module Internal
    module V1
      class RepresentationOrdersController < ApplicationController
        def create
          enforce_contract!
          enqueue_representation_order

          head :accepted
        end

      private

        def enforce_contract!
          unless contract.success?
            raise Errors::ContractError.new(contract, "Representation Order contract")
          end
        end

        def contract
          ProsecutionCaseRepresentationOrderContract.new.call(**transformed_params)
        end

        def create_params
          params.from_jsonapi.require(:representation_order).permit(
            :maat_reference,
            :defendant_id,
            defence_organisation: {},
            offences: %i[
              offence_id
              status_code
              status_date
              effective_start_date
              effective_end_date
            ],
          )
        end

        def transformed_params
          @transformed_params ||= create_params.to_hash.transform_keys(&:to_sym).compact
        end

        def enqueue_representation_order
          ProsecutionCaseRepresentationOrderCreatorWorker.perform_async(
            Current.request_id,
            transformed_params[:defendant_id],
            transformed_params[:offences],
            transformed_params[:maat_reference],
            transformed_params[:defence_organisation],
          )
        end
      end
    end
  end
end
