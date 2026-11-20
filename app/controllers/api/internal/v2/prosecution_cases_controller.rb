# frozen_string_literal: true

module Api
  module Internal
    module V2
      class ProsecutionCasesController < ApplicationController
        # Get/Post /api/internal/v2/prosecution_cases
        def index
          case_summaries = if transformed_params[:prosecution_case_reference].present?
                             find_by_urn(transformed_params[:prosecution_case_reference])
                           elsif transformed_params[:xhibit_case_number].present?
                             find_by_xhibit_case_number
                           else
                             CommonPlatform::Api::SearchProsecutionCase.call(transformed_params)
                           end

          case_summaries_json = Array(case_summaries).map do |case_summary|
            HmctsCommonPlatform::ProsecutionCaseSummary.new(case_summary.body).to_json
          end

          render json: { total_results: case_summaries_json.count, results: case_summaries_json }
        end

        # GET /api/internal/v2/prosecution_cases/:reference/court_applications
        def court_applications
          prosecution_case = CommonPlatform::Api::ProsecutionCaseFinder.call(params[:reference])
          render json: prosecution_case.court_applications.map(&:to_json)
        end

      private

        # Common Platform URN search is case-insensitive,
        # so occasionally two cases have URNs that differ only by case: return both.
        def find_by_urn(urn)
          results = CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference: urn)
          case_summaries = results.select { urn.casecmp?(it.prosecution_case_reference) }
          warn_multiple_cases_for_urn(urn, case_summaries) if case_summaries.count > 1
          case_summaries
        end

        def warn_multiple_cases_for_urn(urn, case_summaries)
          cases = case_summaries.map { "#{it.prosecution_case_reference} (#{it.id})" }.join(", ")

          Sentry.capture_message(
            "#{self.class.name} - URN search for #{urn} returned #{case_summaries.count} cases: #{cases}",
            level: :warning,
          )
        end

        def find_by_xhibit_case_number
          case_urn = XhibitMigratedCase.case_urn_for(transformed_params[:xhibit_case_number])
          CommonPlatform::Api::ProsecutionCaseFinder.call(case_urn) if case_urn
        end

        def transformed_params
          filtered_params.to_hash.deep_symbolize_keys
        end

        def filtered_params
          params.require(:filter).permit(:prosecution_case_reference,
                                         :xhibit_case_number,
                                         :arrest_summons_number,
                                         :name,
                                         :date_of_birth,
                                         :date_of_next_hearing,
                                         :national_insurance_number)
        end
      end
    end
  end
end
