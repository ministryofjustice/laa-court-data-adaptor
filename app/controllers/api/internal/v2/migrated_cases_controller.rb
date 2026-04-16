# frozen_string_literal: true

module Api
  module Internal
    module V2
      class MigratedCasesController < ApplicationController
        DEFAULT_PER_PAGE = 10
        MAX_PER_PAGE = 100

        # GET /api/internal/v2/link_migrated_cases
        def index
          migrated_cases = filtered_cases

          results = paginate(migrated_cases.order(:created_at))

          render json: {
            total_results: migrated_cases.count,
            page: current_page,
            per_page: current_per_page,
            results: results.as_json,
          }
        end

      private

        def filtered_cases
          return XhibitMigratedCase.all if status_filter.blank?
          return XhibitMigratedCase.none unless XhibitMigratedCase.statuses.key?(status_filter)

          XhibitMigratedCase.where(status: status_filter)
        end

        def status_filter
          params[:status].to_s
        end

        def paginate(scope)
          scope.offset((current_page - 1) * current_per_page)
               .limit(current_per_page)
        end

        def current_page
          page_int = params[:page].to_i
          page_int.positive? ? page_int : 1
        end

        def current_per_page
          parsed_value = params[:per_page].to_i
          if (1..MAX_PER_PAGE).cover?(parsed_value)
            parsed_value
          else
            DEFAULT_PER_PAGE
          end
        end
      end
    end
  end
end
