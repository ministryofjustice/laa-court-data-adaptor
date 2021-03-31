# frozen_string_literal: true

module Api
  module Internal
    module V1
      class DefendantsController < ApplicationController
        def show
          defendant = DefendantFinder.call(defendant_id: params[:id])

          if defendant.present?
            render json: DefendantSerializer.new(defendant, serialization_options)
          else
            render status: :not_found
          end
        end

      private

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
