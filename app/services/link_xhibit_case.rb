class LinkXhibitCase < ApplicationService
  TRIAL = "T".freeze
  SENTENCE = "S".freeze
  APPEAL = "A".freeze

  def initialize(maat_search_response, xhibit_case, court_data)
    @maat_search_response = maat_search_response
    @xhibit_case = xhibit_case
    @court_data = court_data
  end

  def call
    case xhibit_case.case_type
    when TRIAL
      ProsecutionCaseMaatLinkCreator.call(court_data.defendant_id, User::SYSTEM_USERNAME, maat_id, can_update_laa_status: true)
    when SENTENCE, APPEAL
      CourtApplicationMaatLinkCreator.call(subject_id, User::SYSTEM_USERNAME, maat_id, can_update_laa_status: true)
    else
      raise ArgumentError, "Unsupported case type: #{xhibit_case.case_type.inspect}"
    end

    xhibit_case.update!(
      maat_id:,
      status: :auto_linked,
      linked_at: Time.zone.now,
      linked_by: User::SYSTEM_USERNAME,
    )
  end

private

  attr_reader :maat_search_response, :xhibit_case, :court_data

  def subject_id
    court_data.application_summaries.first&.subject_summary&.subject_id ||
      raise(ArgumentError, "No court application found for defendant #{court_data.defendant_id}")
  end

  def maat_id
    maat_search_response.maat_id
  end
end
