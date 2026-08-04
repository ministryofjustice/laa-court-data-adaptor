class ProcessXhibitCases < ApplicationService
  NOT_FOUND = 404
  SUCCESS = 200..299

  def call
    XhibitMigratedCase.pending.find_each do |xhibit_case|
      process(xhibit_case)
    end
  end

private

  def process(xhibit_case)
    response = MaatApi::MaatApplicationSearcher.call(
      first_name: xhibit_case.defendant_first_name,
      last_name: xhibit_case.defendant_last_name,
    )

    case response&.status
    when SUCCESS
      # TODO: process the maat applications matching the case.
    when NOT_FOUND
      xhibit_case.action_required!
    else
      record_error(xhibit_case, status: response&.status, body: response&.body)
    end
  rescue Faraday::Error => e
    record_error(xhibit_case, error: e.class.name, message: e.message)
  end

  def record_error(xhibit_case, **process_errors)
    xhibit_case.update!(process_errors:)
  end
end
