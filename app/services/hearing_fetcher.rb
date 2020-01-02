# frozen_string_literal: true

class HearingFetcher < ApplicationService
  include CommonPlatformConnection

  attr_reader :url, :common_platform_shared_secret_key

  def initialize(hearing_id)
    @url = "/hearing/results/#{hearing_id}"
    @common_platform_shared_secret_key = 'COMMON_PLATFORM_SHARED_SECRET_KEY'
  end

  def call
    common_platform_connection.get(url)
  end
end
