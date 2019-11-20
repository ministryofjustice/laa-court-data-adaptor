# frozen_string_literal: true

class ProsecutionCaseSearcher < ApplicationService
  include CommonPlatformConnection

  def initialize(prosecution_case_reference)
    @url = '/prosecutionCases'
    @prosecution_case_reference = prosecution_case_reference
  end

  def call
    common_platform_connection.get(
      url,
      prosecutionCaseReference: prosecution_case_reference
    )
  end

  attr_reader :url, :prosecution_case_reference
end
