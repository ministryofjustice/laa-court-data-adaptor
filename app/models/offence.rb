# frozen_string_literal: true

class Offence
  include ActiveModel::Model

  attr_accessor :body

  def id
    body['offenceId']
  end

  def offence_code_order_index
    body['offenceCodeorderIndex']
  end

  def order_index
    body['orderIndex']
  end

  def offence_title
    body['offenceTitle']
  end

  def offence_legislation
    body['offenceLegislation']
  end

  def wording
    body['wording']
  end

  def arrest_date
    body['arrestDate']
  end

  def charge_date
    body['chargeDate']
  end

  def date_of_information
    body['dateOfInformation']
  end

  def mode_of_trial
    body['modeOfTrial']
  end

  def start_date
    body['startDate']
  end

  def end_date
    body['endDate']
  end

  def proceeding_concluded
    body['proceedingConcluded']
  end

  def application_reference
    body['laaApplnReference']['applicationReference']
  end

  def status_id
    body['laaApplnReference']['statusId']
  end

  def status_code
    body['laaApplnReference']['statusCode']
  end

  def status_description
    body['laaApplnReference']['statusDescription']
  end

  def status_date
    body['laaApplnReference']['statusDate']
  end

  def effective_start_date
    body['laaApplnReference']['effectiveStartDate']
  end

  def effective_end_date
    body['laaApplnReference']['effectiveEndDate']
  end
end
