# frozen_string_literal: true

module Api
  module Internal
    module V2
      class DefendantsController < ApplicationController
        def show
          response_data = CommonPlatform::Api::ProsecutionCaseFetcher.call(
            prosecution_case_reference: params[:prosecution_case_reference],
          ).body

          defendant_summary = HmctsCommonPlatform::SearchProsecutionCaseResponse.new(response_data)
            .cases
            .first
            .defendant_summaries
            .find { |ds| ds.defendant_id.eql?(params[:id]) }

          if defendant_summary.present?
            render json: defendant_summary.to_json
          else
            render json: {}, status: :not_found
          end
        end
      end
    end
  end
end
