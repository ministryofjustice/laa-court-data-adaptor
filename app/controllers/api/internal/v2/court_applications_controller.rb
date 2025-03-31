# frozen_string_literal: true

module Api
  module Internal
    module V2
      class CourtApplicationsController < ApplicationController
        def show
          response_data = CommonPlatform::Api::CourtApplicationSearcher.call(
            application_id: params[:id],
          )
          response_body = response_data.body

          case response_data.status
          when 200
            application_summary = HmctsCommonPlatform::CourtApplicationSummary.new(response_body)
            CourtApplicationRecorder.call(params[:id], application_summary)
            render json: application_summary.to_json, status: :ok
          when 404
            head :not_found
          else
            render json: response_data.body, status: :service_unavailable
          end
        end
      end
    end
  end
end
