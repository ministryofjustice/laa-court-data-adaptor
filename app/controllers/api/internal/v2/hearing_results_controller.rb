# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingResultsController < ApplicationController
        def show
          @hearing = CommonPlatform::Api::GetHearingResults.call(hearing_id: params[:id])
          render json: HearingSerializer.new(@hearing, serialization_options)
        end

      private

        def serialization_options
          return { include: inclusions } if inclusions.present?

          {}
        end

        def inclusions
          params[:include]&.split(",")
        end
      end
    end
  end
end
