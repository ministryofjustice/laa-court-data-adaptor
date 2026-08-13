class ProcessXhibitCases < ApplicationService
  def call
    XhibitMigratedCase.pending.find_each do |xhibit_case|
      process_case(xhibit_case)
    end
  end

private

  def process_case(xhibit_case)
    response = maat_search(xhibit_case)

    handle_response(response, xhibit_case)
  rescue Faraday::Error => e
    record_error(xhibit_case, error: e.class.name, message: e.message)
  end

  def maat_search(xhibit_case)
    MaatApi::MaatApplicationSearcher.call(
      first_name: xhibit_case.defendant_first_name,
      last_name: xhibit_case.defendant_last_name,
      date_of_birth: xhibit_case.defendant_date_of_birth,
      arrest_summons_number: xhibit_case.defendant_arrest_summons_number,
      committal_date: xhibit_case.committal_date,
      case_type: xhibit_case.case_type,
    )
  end

  def handle_response(response, xhibit_case)
    if response.success?
      handle_success(response, xhibit_case)
    elsif response.not_found?
      handle_not_found(xhibit_case)
    else
      record_error(xhibit_case, error: response&.status, message: response&.body)
    end
  end

  def handle_success(response, xhibit_case)
    LinkXhibitCase.call(response, xhibit_case) if response.no_existing_link?
  end

  def handle_not_found(xhibit_case)
    xhibit_case.action_required!
    record_error(xhibit_case, message: "MAAT application not found")
  end

  def record_error(xhibit_case, **process_errors)
    xhibit_case.update!(process_errors: process_errors)
  end
end
