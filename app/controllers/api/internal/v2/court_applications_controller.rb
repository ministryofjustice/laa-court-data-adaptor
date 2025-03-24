# frozen_string_literal: true

module Api
  module Internal
    module V2
      class CourtApplicationsController < ApplicationController
        def show
          response_data = CommonPlatform::Api::CourtApplicationSearcher.call(
            application_id: params[:id],
          ).body

          if response_data.present?
            render json: HmctsCommonPlatform::CourtApplicationSummary.new(response_data).to_json, status: :ok
          else
            head :not_found
          end
        end
      end
    end
  end
end
