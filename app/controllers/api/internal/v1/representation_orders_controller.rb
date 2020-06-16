# frozen_string_literal: true

module Api
  module Internal
    module V1
      class RepresentationOrdersController < ApplicationController
        def create
          contract = NewRepresentationOrderContract.new.call(**transformed_params)
          if contract.success?
            enqueue_representation_order
            render status: :accepted
          else
            render json: contract.errors.to_hash, status: :bad_request
          end
        end

        private

        def create_params
          params.from_jsonapi.require(:representation_order).permit!
        end

        def transformed_params
          @transformed_params ||= create_params.to_hash.transform_keys(&:to_sym).compact
        end

        def enqueue_representation_order
          RepresentationOrderCreatorWorker.perform_async(
            Current.request_id,
            transformed_params[:defendant_id],
            transformed_params[:offences],
            transformed_params[:maat_reference],
            transformed_params[:defence_organisation]
          )
        end
      end
    end
  end
end
