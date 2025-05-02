# frozen_string_literal: true

class Hearing
  attr_reader :data, :load_events

  delegate :blank?, to: :data

  def initialize(data, load_events: true)
    @data = HashWithIndifferentAccess.new(data || {})
    @load_events = load_events
  end

  def id
    data["id"]
  end

  def court_name
    court_centre.name
  end

  def hearing_type
    data["type"]["description"]
  end

  def hearing_days
    Array(data["hearingDays"]).map { |hearing_day| hearing_day["sittingDay"] }
  end

  def defendant_names
    defendants.map do |defendant|
      "#{defendant['personDefendant']['personDetails']['firstName']} #{defendant['personDefendant']['personDetails']['lastName']}"
    end
  end

  def hearing_events
    hearing_day_events.map { |hearing_day_event| HearingEvent.new(body: hearing_day_event) }
  end

  def hearing_event_ids
    hearing_events.map(&:id)
  end

  def judge_names
    Array(data["judiciary"]).map do |judge|
      [judge["title"], judge["firstName"], judge["lastName"]].reject(&:blank?).join(" ")
    end
  end

  def prosecution_advocate_names
    Array(data["prosecutionCounsels"]).map do |prosecution_counsel|
      "#{prosecution_counsel['firstName']} #{prosecution_counsel['lastName']}"
    end
  end

  def defence_advocate_names
    Array(data["defenceCounsels"]).map do |defence_counsel|
      "#{defence_counsel['firstName']} #{defence_counsel['lastName']}"
    end
  end

  def providers
    data["defenceCounsels"]&.map { |defence_counsel| Provider.new(body: defence_counsel) }
  end

  def provider_ids
    data["defenceCounsels"]&.map { |defence_counsel| defence_counsel["id"] }
  end

  def cracked_ineffective_trial
    return if common_platform_cracked_ineffective_trial.blank?

    CrackedIneffectiveTrial.new(body: common_platform_cracked_ineffective_trial)
  end

  def cracked_ineffective_trial_id
    common_platform_cracked_ineffective_trial&.fetch("id", nil)
  end

  def court_application_ids
    court_applications.map(&:id)
  end

  def prosecution_case_ids
    prosecution_cases.map(&:id)
  end

  def defendant_judicial_result_ids
    defendant_judicial_results.map(&:id)
  end

  def court_applications
    Array(data["courtApplications"]).map do |court_application_data|
      HmctsCommonPlatform::CourtApplication.new(court_application_data)
    end
  end

  def prosecution_cases
    Array(prosecution_cases_data).map do |prosecution_case_data|
      HmctsCommonPlatform::ProsecutionCase.new(prosecution_case_data)
    end
  end

  def defendant_judicial_results
    Array(data["defendantJudicialResults"]).map do |defendant_judicial_result_data|
      HmctsCommonPlatform::DefendantJudicialResult.new(defendant_judicial_result_data)
    end
  end

private

  def prosecution_cases_data
    data["prosecutionCases"]
  end

  def defendants
    Array(prosecution_cases_data).flat_map { |prosecution_case| prosecution_case["defendants"] }
  end

  def hearing_event_recordings
    return [] unless load_events

    @hearing_event_recordings ||= Array(data["hearingDays"]).flat_map { |hearing_day|
      CommonPlatform::Api::GetHearingEvents.call(hearing_id: id, hearing_date: hearing_day["sittingDay"].to_date)
    }.compact
  end

  def hearing_day_events
    hearing_event_recordings.flat_map { |recording| recording.body["events"] }.compact
  end

  def court_centre
    HmctsCommonPlatform::CourtCentre.new(data["courtCentre"])
  end

  def common_platform_cracked_ineffective_trial
    data["crackedIneffectiveTrial"]
  end
end
