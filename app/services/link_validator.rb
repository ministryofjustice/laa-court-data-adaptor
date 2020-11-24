# frozen_string_literal: true

class LinkValidator < ApplicationService
  def initialize(defendant_id:)
    @prosecution_case = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)&.prosecution_case
  end

  def call
    prosecution_case&.hearing_summaries&.present? || false
  end

  private

  attr_reader :prosecution_case
end
