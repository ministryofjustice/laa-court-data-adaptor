# frozen_string_literal: true

class ProsecutionCaseRecorder < ApplicationService
  def initialize(prosecution_case_id:, body:)
    @prosecution_case = ProsecutionCase.find_or_initialize_by(id: prosecution_case_id)
    @body = body
  end

  def call
    prosecution_case.update!(body:)

    # A lock on the case helps avoid 2 simultaneous processes creating duplicate records
    prosecution_case.with_lock { create_offence_records }

    prosecution_case
  end

private

  attr_reader :prosecution_case, :body

  def create_offence_records
    # Pull all existing records out of the DB in a single query here and
    # retain them in memory as an array. That way, in the most common case,
    # where the records already exist, no further DB interactions are needed,
    # so we avoid an N+1 query issue.
    local_records = prosecution_case.prosecution_case_defendant_offences.to_a

    prosecution_case.defendants.each do |defendant|
      defendant.offences.each do |offence|
        next if local_records.any? { |record| record.defendant_id == defendant.id && record.offence_id == offence.id }

        ProsecutionCaseDefendantOffence.create!(
          prosecution_case_id: prosecution_case.id,
          defendant_id: defendant.id,
          offence_id: offence.id,
        )
      end
    end
  end
end
