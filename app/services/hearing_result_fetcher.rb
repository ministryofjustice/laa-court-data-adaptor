# frozen_string_literal: true

class HearingResultFetcher < ApplicationService
  def initialize(hearing_id)
    @hearing_id = hearing_id
  end

  def call
    connection.get("/hearing/results/#{hearing_id}")
  end

  private

  def connection
    @connection ||= Faraday.new ENV.fetch('COMMON_PLATFORM_URL') do |conn|
      conn.response :json, content_type: 'application/json'
      conn.adapter Faraday.default_adapter
    end
  end

  attr_reader :hearing_id
end
