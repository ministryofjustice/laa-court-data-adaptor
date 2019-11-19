# frozen_string_literal: true

class HearingFetcher < ApplicationService
  include CommonPlatformConnection

  def initialize(hearing_id)
    @url = "/hearing/results/#{hearing_id}"
  end

  def call
    common_platform_connection.get(url)
  end

  attr_reader :url
end
