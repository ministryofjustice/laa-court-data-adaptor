# frozen_string_literal: true

module Api
  module Internal
    module V2
      class CourtApplicationController < ApplicationController
        def show
          # court_application = CommonPlatform::Api::GetCourtApplication.call(
          #                       court_application_id: params[:id]
          #                     )

          render json: {}
        end
      end
    end
  end
end
