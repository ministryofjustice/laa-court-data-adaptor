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

  def mode_of_trial_reasons
    allocation_decisions.map { |decision|
      {
        description: decision["motReasonDescription"],
        code: decision["motReasonCode"],
      }
    }.uniq
  end

  def judicial_result_ids
    judicial_results.map(&:id)
  end

  def judicial_results
    judicial_results_array.map do |judicial_result_data|
      HmctsCommonPlatform::JudicialResult.new(judicial_result_data)
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
        originating_hearing_id: plea["originatingHearingId"],
      }
    end
  end

  def verdict
    HmctsCommonPlatform::Verdict.new(body["verdict"])
  end

private

  def laa_reference
    body["laaApplnReference"]
  end

  def pleas_array
    if details.blank?
      body["plea"] ||= []
    else
      details.flat_map { |detail| detail["plea"] }.uniq.compact
    end
  end

  def judicial_results_array
    return [] if details.blank?

    details.flat_map { |detail| detail["judicialResults"] }.uniq.compact
  end

  def allocation_decisions
    return [] if details.blank?

    details.flat_map { |detail| detail["allocationDecision"] }.compact
  end
end
