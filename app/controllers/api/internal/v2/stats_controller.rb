# frozen_string_literal: true

module Api
  module Internal
    module V2
      class StatsController < ApplicationController
        def index_linking
          date_from = Date.parse(params.fetch(:from, ""))
          date_to = Date.parse(params.fetch(:to, ""))
          render json: LinkingStatCollator.call(date_from, date_to)
        rescue Date::Error
          head :unprocessable_content
        end
      end
    end
  end
end
