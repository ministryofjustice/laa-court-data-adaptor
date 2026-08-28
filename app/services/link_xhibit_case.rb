class LinkXhibitCase < ApplicationService
  TRIAL = "T".freeze
  SENTENCE = "S".freeze
  APPEAL = "A".freeze
  USER_NAME = "SYSTEM".freeze

  def initialize(maat_search_response, xhibit_case, court_data)
    @maat_search_response = maat_search_response
    @xhibit_case = xhibit_case
    @court_data = court_data
  end

  def call
    case xhibit_case.case_type
    when TRIAL
      ProsecutionCaseMaatLinkCreator.call(court_data.defendant_id, USER_NAME, maat_id)
    when SENTENCE, APPEAL
      CourtApplicationMaatLinkCreator.call(subject_id, USER_NAME, maat_id)
    else
      raise ArgumentError, "Unsupported case type: #{xhibit_case.case_type.inspect}"
    end

    xhibit_case.update!(
      maat_id:,
      status: :auto_linked,
      linked_at: Time.zone.now,
      linked_by: USER_NAME,
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
