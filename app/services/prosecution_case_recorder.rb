# frozen_string_literal: true

class ProsecutionCaseRecorder < ApplicationService
  def initialize(prosecution_case_id:, body:)
    @prosecution_case_id = prosecution_case_id
    @body = body
  end

  def call
    # Lock the whole table while we establish if we are creating or updating
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("LOCK prosecution_cases IN ACCESS EXCLUSIVE MODE")
      @prosecution_case = ProsecutionCase.find_or_initialize_by(id: prosecution_case_id)
      prosecution_case.update!(body:)
    end

    # A lock on the case helps avoid 2 simultaneous processes creating duplicate records
    prosecution_case.with_lock { sync_offence_records }

    prosecution_case
  end

private

  attr_reader :prosecution_case, :prosecution_case_id, :body

  def sync_offence_records
    # Pull all existing records out of the DB in a single query here and
    # retain them in memory as an array. That way, in the most common case,
    # where the records already exist, no further DB interactions are needed,
    # so we avoid an N+1 query issue.
    local_records = prosecution_case.prosecution_case_defendant_offences.map do |defendant_offence|
      { offence_id: defendant_offence.offence_id, defendant_id: defendant_offence.defendant_id }
    end

    remote_records = prosecution_case.defendants.flat_map do |defendant|
      defendant.offences.map { { offence_id: it.id, defendant_id: defendant.id } }
    end

    new_records = remote_records - local_records

    new_records.each do |attrs|
      ProsecutionCaseDefendantOffence.create!(
        prosecution_case_id: prosecution_case.id,
        defendant_id: attrs[:defendant_id],
        offence_id: attrs[:offence_id],
      )
    end

    # Common Platform sometimes includes the wrong defendant, then removes it later.
    # Our system needs to clean up any old incorrect records whenever we get a new payload,
    # to avoid problems with MAAT linking later.
    removed_records = local_records - remote_records

    removed_records.each do |attrs|
      ProsecutionCaseDefendantOffence.find_by(
        prosecution_case_id: prosecution_case.id,
        defendant_id: attrs[:defendant_id],
        offence_id: attrs[:offence_id],
      )&.destroy
    end

    ProsecutionCaseDefendantOffence.where(defendant_id: prosecution_case.defendant_ids)
                                   .where.not(prosecution_case_id: prosecution_case.id)
                                   .destroy_all
  end
end
