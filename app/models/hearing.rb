# frozen_string_literal: true

class Hearing < ApplicationRecord
  validates :body, presence: true

  def court_name
    court_centre.name
  end

  def hearing_type
    hearing_body["type"]["description"]
  end

  def hearing_days
    Array(hearing_body["hearingDays"]).map { |hearing_day| hearing_day["sittingDay"] }
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
    Array(hearing_body["judiciary"]).map do |judge|
      [judge["title"], judge["firstName"], judge["lastName"]].reject(&:blank?).join(" ")
    end
  end

  def prosecution_advocate_names
    Array(hearing_body["prosecutionCounsels"]).map do |prosecution_counsel|
      "#{prosecution_counsel['firstName']} #{prosecution_counsel['lastName']}"
    end
  end

  def defence_advocate_names
    Array(hearing_body["defenceCounsels"]).map do |defence_counsel|
      "#{defence_counsel['firstName']} #{defence_counsel['lastName']}"
    end
  end

  def providers
    hearing_body["defenceCounsels"]&.map { |defence_counsel| Provider.new(body: defence_counsel) }
  end

  def provider_ids
    hearing_body["defenceCounsels"]&.map { |defence_counsel| defence_counsel["id"] }
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

  def court_applications
    Array(hearing_body["courtApplications"]).map do |court_application_data|
      HmctsCommonPlatform::CourtApplication.new(court_application_data)
    end
  end

private

  def hearing_body
    body["hearing"]
  end

  def prosecution_cases
    hearing_body["prosecutionCases"]
  end

  def defendants
    Array(prosecution_cases).flat_map { |prosecution_case| prosecution_case["defendants"] }
  end

  def hearing_event_recordings
    @hearing_event_recordings ||= Array(hearing_body["hearingDays"]).flat_map { |hearing_day|
      CommonPlatformApi::GetHearingEvents.call(hearing_id: id, hearing_date: hearing_day["sittingDay"].to_date)
    }.compact
  end

  def hearing_day_events
    hearing_event_recordings.flat_map { |recording| recording.body["events"] }.compact
  end

  def court_centre
    HmctsCommonPlatform::CourtCentre.new(hearing_body["courtCentre"])
  end

  def common_platform_cracked_ineffective_trial
    hearing_body["crackedIneffectiveTrial"]
  end
end
