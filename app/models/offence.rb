# frozen_string_literal: true

class Offence
  include ActiveModel::Model

  attr_accessor :body, :details

  def id
    body["offenceId"]
  end

  def code
    body["offenceCode"]
  end

  def order_index
    body["orderIndex"]
  end

  def title
    body["offenceTitle"]
  end

  def legislation
    body["offenceLegislation"]
  end

  def mode_of_trial
    body["modeOfTrial"]
  end

  def mode_of_trial_reason
    allocation_decisions.dig(0, "motReasonDescription")
  end

  def mode_of_trial_reason_code
    allocation_decisions.dig(0, "motReasonCode")
  end

  def mode_of_trial_reasons
    allocation_decisions.map do |decision|
      {
        description: decision["motReasonDescription"],
        code: decision["motReasonCode"],
      }
    end
  end

  def maat_reference
    laa_reference["applicationReference"] if laa_reference.present?
  end

  def pleas
    pleas_array.map do |plea|
      {
        code: plea["pleaValue"],
        pleaded_at: plea["pleaDate"],
      }
    end
  end

private

  def laa_reference
    body["laaApplnReference"]
  end

  def pleas_array
    return [] if details.blank?

    details.flat_map { |detail| detail["plea"] }.uniq.compact
  end

  def allocation_decisions
    return [] if details.blank?

    details.flat_map { |detail| detail["allocationDecision"] }.uniq.compact
  end
end
