# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingEventLogsController < ApplicationController
        def show
          hearing_event_log_response = CommonPlatform::Api::GetHearingEvents.call(
            hearing_id: params[:hearing_id],
            hearing_date: params[:hearing_date],
          )

          if hearing_event_log_response.present?
            render json: HmctsCommonPlatform::HearingEventLog.new(hearing_event_log_response.body).to_json, status: :ok
          else
            render json: {}, status: :not_found
          end
        end
      end
    end
  end
end
