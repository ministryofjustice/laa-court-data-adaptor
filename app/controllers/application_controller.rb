# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_transaction_id
  before_action :doorkeeper_authorize!

  ERROR_MAPPINGS = {
    ActionController::ParameterMissing => :bad_request,
    Errors::ContractError => :unprocessable_entity,
    Errors::DefendantError => :unprocessable_entity,
    Errors::CommonPlatformConnectionFailureError => :service_unavailable,
    ActiveRecord::RecordNotFound => :not_found,
    CommonPlatform::Api::Errors::FailedDependency => :failed_dependency,
  }.freeze

  ERROR_MAPPINGS.each do |klass, status|
    rescue_from klass do |error|
      render(json: { error:, error_codes: error.try(:codes) }, status:)

      unless klass == Errors::ContractError
        Sentry.capture_exception(
          error,
          tags: {
            request_id: Current.request_id,
            defendant_id: params[:defendant_id],
            hearing_id: params.dig(:hearing, :id),
          },
        )
      end
    end
  end

private

  def set_transaction_id
    Current.request_id = request.headers["X-Request-ID"] || request.request_id
    response.set_header("X-Request-ID", Current.request_id)
  end
end
