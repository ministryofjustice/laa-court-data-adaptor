# frozen_string_literal: true

class DefendantFinder < ApplicationService
  def initialize(defendant_id:)
    @defendant_id = defendant_id
    @prosecution_case_defendant = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)
  end

  def call
    ProsecutionCase.find(prosecution_case_defendant.prosecution_case_id).defendants.find { |defendant| defendant.id == defendant_id } if prosecution_case_defendant.present?
  end

  private

  attr_reader :defendant_id, :prosecution_case_defendant
end
