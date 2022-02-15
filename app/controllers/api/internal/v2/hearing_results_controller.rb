# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingResultsController < ApplicationController
        def show
          hearing_result = CommonPlatform::Api::GetHearingResults.call(hearing_id: params[:id])

          render json: HmctsCommonPlatform::HearingResulted.new(hearing_result&.body).to_json, status: :ok
        end
      end
    end
  end
end
