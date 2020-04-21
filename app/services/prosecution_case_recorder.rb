# frozen_string_literal: true

class ProsecutionCaseRecorder < ApplicationService
  def initialize(prosecution_case_id:, body:)
    @prosecution_case = ProsecutionCase.find_or_initialize_by(id: prosecution_case_id)
    @body = body
  end

  def call
    prosecution_case.update(body: body)

    prosecution_case.defendants.each do |defendant|
      defendant.offences.each do |offence|
        ProsecutionCaseDefendantOffence.find_or_create_by!(prosecution_case_id: prosecution_case.id, defendant_id: defendant.id, offence_id: offence.id)
      end
    end

    prosecution_case
  end

  private

  attr_reader :prosecution_case, :body
end
