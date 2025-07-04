# frozen_string_literal: true

module Api
  module Internal
    module V2
      class DefendantsController < ApplicationController
        def show
          response_data = CommonPlatform::Api::ProsecutionCaseFinder.call(
            params[:prosecution_case_reference],
            params[:id],
          )&.body

          return head :not_found unless response_data

          defendant_summary = HmctsCommonPlatform::ProsecutionCaseSummary.new(response_data)
            .defendant_summaries
            .find { |ds| ds.defendant_id.eql?(params[:id]) }

          if defendant_summary.present?
            render json: defendant_summary.to_json
          else
            render json: {}, status: :not_found
          end
        end

        def offence_history
          prosecution_case = CommonPlatform::Api::ProsecutionCaseFinder.call(params[:prosecution_case_reference])
          prosecution_case&.load_hearing_results(params[:id], load_events: false)
          defendant = prosecution_case&.defendants&.find { it.id == params[:id] }

          if defendant
            render json: {
              defendant_id: params[:id],
              offence_histories: defendant.offences.map do |offence|
                { id: offence.id, pleas: offence.pleas, mode_of_trial_reasons: offence.mode_of_trial_reasons }
              end,
            }
          else
            head :not_found
          end
        end
      end
    end
  end
end
