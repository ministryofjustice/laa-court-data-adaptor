# frozen_string_literal: true

module Api
  module Internal
    module V2
      class DefendantsController < ApplicationController

        def show
          defendant = CommonPlatform::Api::DefendantFinder.call(defendant_id: params[:id])

          if defendant.present?
            render json: DefendantSerializer.new(defendant, serialization_options)
          else
            render json: {}, status: :not_found
          end
        end

      private

        def transformed_params
          @transformed_params ||= unlink_params.slice(*allowed_params).to_hash.transform_keys(&:to_sym).merge(defendant_id: params[:id])
        end

        def serialization_options
          return { include: inclusions } if params[:include].present?

          {}
        end

        def inclusions
          params[:include].split(",")
        end
      end
    end
  end
end
