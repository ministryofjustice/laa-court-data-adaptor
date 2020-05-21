# frozen_string_literal: true

module Api
  module Internal
    module V1
      class HearingsController < ApplicationController
        def show
          @hearing = Api::GetHearingResults.call(params[:id])
          render json: HearingSerializer.new(@hearing, serialization_options)
        end

        private

        def serialization_options
          return { include: params[:include].split(',') } if params[:include].present?

          {}
        end
      end
    end
  end
end
