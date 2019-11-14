# frozen_string_literal: true

class ApplicationController < ActionController::API
  ERROR_MAPPINGS = {
    ActionController::ParameterMissing => :bad_request
  }.freeze

  ERROR_MAPPINGS.each do |klass, status|
    rescue_from klass do |error|
      render json: { error: error }, status: status
    end
  end
end
