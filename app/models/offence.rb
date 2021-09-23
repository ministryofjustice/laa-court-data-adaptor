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

  def judicial_results
    return [] if details.blank?

    judicial_results_array.map do |judicial_result|
      {
        cjs_code: judicial_result["cjsCode"],
        is_adjournement_result: judicial_result["isAdjournmentResult"],
        is_available_for_court_extract: judicial_result["isAvailableForCourtExtract"],
        is_convicted_result: judicial_result["isConvictedResult"],
        is_financial_result: judicial_result["isFinancialResult"],
        label: judicial_result["label"],
        ordered_date: judicial_result["orderedDate"],
        qualifier: judicial_result["qualifier"],
        result_text: judicial_result["resultText"],
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

  def judicial_results_array
    details.flat_map { |detail| detail["judicialResults"] }.uniq.compact
  end

  def allocation_decisions
    return [] if details.blank?

    details.flat_map { |detail| detail["allocationDecision"] }.compact
  end
end
