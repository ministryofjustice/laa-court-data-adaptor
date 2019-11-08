# frozen_string_literal: true

class StatusController < ApplicationController
  def index
    render head: :ok
  end
end
