# frozen_string_literal: true

module Api
  module Internal
    module V2
      class DefendantsController < ApplicationController
        def show
          prosecution_case = CommonPlatform::Api::ProsecutionCaseFinder.call(params[:prosecution_case_reference])
          return head :not_found unless prosecution_case

          defendant_summary = HmctsCommonPlatform::ProsecutionCaseSummary.new(prosecution_case.body)
                                                                         .defendant_summary(params[:id])

          if defendant_summary.present?
            render json: defendant_summary.to_json
          else
            render json: {}, status: :not_found
          end
        end

        def offence_history
          defendant = CommonPlatform::Api::DefendantFinder.call(
            defendant_id: params[:id],
            urn: params[:prosecution_case_reference],
          )

          if defendant
            render json: defendant.offence_history
          else
            head :not_found
          end
        end
      end
    end
  end
end
