class DefendantFinder < ApplicationService

  def initialize(defendant_id:)
    @defendant_id = defendant_id
    @prosecution_case_defendant = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)
  end

  def call
    if prosecution_case_defendant.present?
      ProsecutionCase.find(prosecution_case_defendant.prosecution_case_id).defendants.select{|defendant| defendant.id == defendant_id}.first
    end
  end

  private

  attr_reader :defendant_id, :prosecution_case_defendant
end
