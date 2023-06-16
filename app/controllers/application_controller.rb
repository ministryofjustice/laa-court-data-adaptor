# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_transaction_id
  before_action :doorkeeper_authorize!
  before_action :log_http_request_headers

  ERROR_MAPPINGS = {
    ActionController::ParameterMissing => :bad_request,
    Errors::ContractError => :unprocessable_entity,
    Errors::DefendantError => :unprocessable_entity,
    ActiveRecord::RecordNotFound => :not_found,
    CommonPlatform::Api::Errors::FailedDependency => :failed_dependency,
  }.freeze

  ERROR_MAPPINGS.each do |klass, status|
    rescue_from klass do |error|
      render json: { error: error }, status: status

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

private

  def log_http_request_headers
    http_request_headers = {}.tap do |envs|
      request.headers.each do |key, value|
        envs[key] = value if key.downcase.starts_with?("http")
      end
    end

    Rails.logger.info(http_request_headers)
  end

  def set_transaction_id
    Current.request_id = request.headers["X-Request-ID"] || request.request_id
    response.set_header("X-Request-ID", Current.request_id)
  end
end
