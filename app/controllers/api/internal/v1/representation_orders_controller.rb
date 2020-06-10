# frozen_string_literal: true

module Api
  module Internal
    module V1
      class RepresentationOrdersController < ApplicationController
        def create
          contract = NewRepresentationOrderContract.new.call(**transformed_params)
          if contract.success?
            RepresentationOrderCreatorJob.perform_later(contract: transformed_params, request_id: Current.request_id)
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
          create_params.to_hash.transform_keys(&:to_sym).compact
        end
      end
    end
  end
end
