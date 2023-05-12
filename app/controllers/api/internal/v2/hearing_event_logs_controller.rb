# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingEventLogsController < ApplicationController
        def show
          hearing_event_log_response = CommonPlatform::Api::GetHearingEvents.call(
            hearing_id: hearing_id,
            hearing_date: hearing_date,
          )

          if hearing_event_log_response.present?
            render json: HmctsCommonPlatform::HearingEventLog.new(hearing_event_log_response.body).to_json, status: :ok
          else
            render json: { error: unsuccess_error_message }, status: :not_found
          end
        end

      private

        def hearing_id
          params[:hearing_id]
        end

        def hearing_date
          params[:hearing_date]
        end

        def unsuccess_error_message
          "The hearing '#{hearing_id}' on the '#{hearing_date}' was not found, " \
            "or a Server Error occurred on the Common Platform API."
        end
      end
    end
  end
end
