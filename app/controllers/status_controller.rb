# frozen_string_literal: true

class StatusController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: %i[index ping]

  def index
    render head: :ok
  end

  def ping
    render json: {
      "app_branch" => ENV.fetch("APP_BRANCH", "Not Available"),
      "build_date" => ENV.fetch("BUILD_DATE", "Not Available"),
      "build_tag" => ENV.fetch("BUILD_TAG", "Not Available"),
      "commit_id" => ENV.fetch("COMMIT_ID", "Not Available"),
    }
  end
end
