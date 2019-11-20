# frozen_string_literal: true

class ProsecutionCaseRecorder < ApplicationService
  def initialize(prosecution_case_id, body)
    @prosecution_case =
      ProsecutionCase.find_or_initialize_by(id: prosecution_case_id)
    @body = body
  end

  def call
    prosecution_case.update(body: body)
    prosecution_case
  end

  private

  attr_reader :prosecution_case, :body
end
