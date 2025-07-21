# frozen_string_literal: true

class ProsecutionCaseRecorder < ApplicationService
  def initialize(prosecution_case_id:, body:)
    @prosecution_case = ProsecutionCase.find_or_initialize_by(id: prosecution_case_id)
    @body = body
  end

  def call
    prosecution_case.update!(body:)

    # A lock on the case helps avoid 2 simultaneous processes creating duplicate records
    prosecution_case.with_lock { sync_offence_records }

    prosecution_case
  end

private

  attr_reader :prosecution_case, :body

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

    need_to_be_created = remote_records - local_records

    need_to_be_created.each do |attrs|
      ProsecutionCaseDefendantOffence.create!(
        prosecution_case_id: prosecution_case.id,
        defendant_id: attrs[:defendant_id],
        offence_id: attrs[:offence_id],
      )
    end

    # Sometimes Common Platform erroneously includes a defendant ID from one case
    # in the payload for a different case, then later removes it. Our system is vulnerable
    # to creating ProsecutionCaseDefendantOffence records based on the error, then not
    # removing them again, leading to problems when we use these records to do MAAT linking.
    # So any time we receive a payload from Common Platform we check for and remove records
    # that should not be there.
    need_to_be_deleted = local_records - remote_records

    need_to_be_deleted.each do |attrs|
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
