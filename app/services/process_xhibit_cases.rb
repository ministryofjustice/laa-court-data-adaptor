class ProcessXhibitCases < ApplicationService
  def call
    XhibitMigratedCase.pending.find_each do |xhibit_case|
      response = maat_search(xhibit_case)

      if response.success?
        handle_success(response, xhibit_case)
      elsif response.not_found?
        handle_not_found(xhibit_case)
      else
        record_error(xhibit_case, :maat, error: response&.status, message: response&.body)
      end
    rescue StandardError => e
      record_error(xhibit_case, :unexpected, error: e.class.name, message: e.message)
    end
  end

private

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

  def handle_success(response, xhibit_case)
    if response.existing_link?
      xhibit_case.action_required!
      record_error(xhibit_case, :maat, message: existing_link_message(response))
      return
    end

    defendant_summary = fetch_defendant_summary(xhibit_case)

    if defendant_summary.nil?
      # Handle not on common_platform
      xhibit_case.action_required!
      record_error(xhibit_case, :common_platform, message: "Case not found on Common Platform")
      return
    end

    LinkXhibitCase.call(response, xhibit_case, defendant_summary)
  rescue ActiveRecord::RecordInvalid => e
    record_error(xhibit_case, :link, message: "Validation failed: #{e.record.errors.full_messages.join(', ')}")
  end

  # Both MAAT link creators read from the local database, so the case has to be
  # searched for (and therefore recorded) before anything can be linked.
  # Searching also records the offences the link is posted against.
  def fetch_defendant_summary(xhibit_case)
    prosecution_case = search_prosecution_case(xhibit_case)
    return if prosecution_case.nil?

    HmctsCommonPlatform::ProsecutionCaseSummary
      .new(prosecution_case.body)
      .defendant_summary(xhibit_case.defendant_id)
  end

  # Common Platform's URN search is case insensitive and strips spaces, so it can
  # return more than one case
  def search_prosecution_case(xhibit_case)
    cases = Array(
      CommonPlatform::Api::SearchProsecutionCase.call(
        prosecution_case_reference: xhibit_case.case_urn,
      ),
    )

    cases.find { it.prosecution_case_reference == xhibit_case.case_urn } ||
      (cases.first if cases.one?)
  end

  def handle_not_found(xhibit_case)
    xhibit_case.action_required!
    record_error(xhibit_case, :maat, message: "MAAT application not found")
  end

  def existing_link_message(response)
    if response.linked_to_common_platform?
      "MAAT ID already linked with other CP case (#{response.linked_case_urn})"
    else
      "MAAT application is already linked"
    end
  end

  # Errors are keyed by step and merged, so that a failure in one step does not
  # discard what an earlier step recorded.
  def record_error(xhibit_case, step, **details)
    xhibit_case.reload.update_columns(
      process_errors: (xhibit_case.process_errors || {}).merge(step.to_s => details.stringify_keys),
      updated_at: Time.zone.now,
    )
  end
end
