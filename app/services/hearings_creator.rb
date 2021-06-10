# frozen_string_literal: true

class HearingsCreator < ApplicationService
  attr_reader :hearing_resulted

  def initialize(hearing_resulted_data:)
    @hearing_resulted = HmctsCommonPlatform::HearingResulted.new(hearing_resulted_data)
  end

  def call
    push_prosecution_cases
    push_applications
  end

private

  def push_prosecution_cases
    hearing[:prosecutionCases]&.each do |prosecution_case_data|
      prosecution_case_data[:defendants].each do |defendant_data|
        next if defendant_data[:offences].any? { |offence| offence.dig(:laaApplnReference, :applicationReference)&.start_with?("A", "Z") }

        laa_reference = LaaReference.find_by!(defendant_id: defendant_data[:id], linked: true)

        prosecution_case = MaatApi::ProsecutionCase.new(
          hearing_body,
          prosecution_case_data[:prosecutionCaseIdentifier][:caseURN],
          defendant_data,
          laa_reference.maat_reference,
        )
        Sqs::MessagePublisher.call(
          message: MaatApi::Message.new(prosecution_case).generate,
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      end
    end
  end

  def push_applications
    hearing[:courtApplications]&.each do |court_application_data|
      defendant_cases = court_application_data.dig(:applicant, :masterDefendant, :defendantCase) || []

      defendant_cases.each do |defendant_case|
        laa_reference = LaaReference.find_by(defendant_id: defendant_case[:defendantId], linked: true)

        next if laa_reference.blank?

        court_application = MaatApi::CourtApplication.new(
          hearing_body,
          court_application_data,
          laa_reference.maat_reference,
        )

        Sqs::MessagePublisher.call(
          message: MaatApi::Message.new(court_application).generate,
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      end
    end
  end

  attr_reader :shared_time, :hearing
end
