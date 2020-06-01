# frozen_string_literal: true

class HearingsCreator < ApplicationService
  # rubocop:disable Naming/MethodParameterName
  # rubocop:disable Naming/VariableName
  def initialize(sharedTime:, hearing:)
    @shared_time = sharedTime
    @hearing = hearing
  end
  # rubocop:enable Naming/MethodParameterName
  # rubocop:enable Naming/VariableName

  def call
    hearing[:prosecutionCases].each do |prosecution_case|
      prosecution_case[:defendants].each do |defendant|
        next if defendant[:laaApplnReference][:applicationReference]&.start_with?('A', 'Z')

        push_to_sqs(shared_time: shared_time,
                    case_urn: prosecution_case[:prosecutionCaseIdentifier][:caseURN],
                    defendant: defendant)
      end
    end
  end

  private

  def push_to_sqs(shared_time:, case_urn:, defendant:)
    return unless jurisdiction_type == 'MAGISTRATES'

    Sqs::PublishMagistratesHearing.call(shared_time: shared_time,
                                        jurisdiction_type: jurisdiction_type,
                                        case_urn: case_urn,
                                        defendant: defendant,
                                        cjs_location: cjs_location)
  end

  def jurisdiction_type
    @jurisdiction_type ||= hearing[:jurisdictionType]
  end

  def cjs_location
    @cjs_location ||= hearing.dig(:courtCentre, :ouCode)
  end

  attr_reader :shared_time, :hearing
end
