# frozen_string_literal: true

module Api
  module Internal
    module V2
      class MigratedCasesController < ApplicationController
        DEFAULT_PER_PAGE = 10
        MAX_PER_PAGE = 100
        SORTABLE_FIELDS = {
          "case_urn" => %w[case_urn],
          "xhibit_case_number" => %w[xhibit_case_number],
          "case_type" => %w[case_type],
          "court_name" => %w[court_name],
          "defendant_name" => %w[defendant_first_name defendant_last_name],
          "created_at" => %w[created_at],
          "maat_id" => %w[maat_id],
          "linked_by" => %w[linked_by],
          "status" => %w[status],
        }.freeze

        # GET /api/internal/v2/link_migrated_cases
        def index
          migrated_cases = filtered_cases
          ordered_cases = sorted_cases(migrated_cases)

          results = paginate(ordered_cases)

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

        def sorted_cases(scope)
          sort_by = params[:sort_by].presence || "created_at"
          sort_direction = params[:sort_direction].to_s.downcase.presence || "asc"

          unless SORTABLE_FIELDS.key?(sort_by) && %w[asc desc].include?(sort_direction)
            sort_by = "created_at"
            sort_direction = "asc"
          end

          order_columns = SORTABLE_FIELDS.fetch(sort_by) + %w[id]
          order_direction = sort_direction.to_sym

          order_columns.reduce(scope) do |relation, column|
            relation.order(column => order_direction)
          end
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
