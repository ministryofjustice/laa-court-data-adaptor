# frozen_string_literal: true

class StatusController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: [:index]
  def index
    render head: :ok
  end
end
