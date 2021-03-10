# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_transaction_id
  before_action :doorkeeper_authorize!

  ERROR_MAPPINGS = {
    ActionController::ParameterMissing => :bad_request,
    ActiveRecord::RecordInvalid => :bad_request,
    Errors::ContractError => :unprocessable_entity,
  }.freeze

  ERROR_MAPPINGS.each do |klass, status|
    rescue_from klass do |error|
      render json: { error: error }, status: status

      Sentry.capture_message(
        error,
        tags: {
          request_id: Current.request_id,
          defendant_id: params.dig(:defendant_id),
          hearing_id: params.dig(:hearing, :id),
        },
      )
    end
  end

private

  def set_transaction_id
    Current.request_id = request.headers["Laa-Transaction-Id"] || request.request_id
    response.set_header("Laa-Transaction-Id", Current.request_id)
  end
end
