# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate

  ERROR_MAPPINGS = {
    ActionController::ParameterMissing => :bad_request
  }.freeze

  ERROR_MAPPINGS.each do |klass, status|
    rescue_from klass do |error|
      render json: { error: error }, status: status
    end
  end

  private

  def authenticate
    user = authenticate_with_http_token do |token, options|
      User.find_by(id: options[:user_id])&.authenticate_auth_token(token)
    end

    head :unauthorized if user.blank?
  end
end
