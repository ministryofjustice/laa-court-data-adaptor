# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_transaction_id
  before_action :doorkeeper_authorize!

  ERROR_MAPPINGS = {
    ActionController::ParameterMissing => :bad_request
  }.freeze

  ERROR_MAPPINGS.each do |klass, status|
    rescue_from klass do |error|
      render json: { error: error }, status: status
    end
  end

  private

  def set_transaction_id
    Current.request_id = request.request_id
    response.set_header('Laa-Transaction-Id', Current.request_id)
  end
end
