# frozen_string_literal: true

class HearingsCreator < ApplicationService
  def initialize(hearing:)
    @hearing = hearing
  end

  def call
    hearing[:hearing][:prosecutionCases].each do |prosecution_case|
      prosecution_case[:defendants].each do |defendant|
        push_to_sqs(shared_time: shared_time,
                    case_status: prosecution_case[:caseStatus],
                    case_urn: prosecution_case[:caseURN],
                    defendant: defendant)
      end
    end
  end

  private

  def push_to_sqs(shared_time:, case_status:, case_urn:, defendant:)
    return unless jurisdiction_type == 'MAGISTRATES'

    Sqs::PublishMagistratesHearing.call(shared_time: shared_time,
                                        jurisdiction_type: jurisdiction_type,
                                        case_status: case_status,
                                        case_urn: case_urn,
                                        defendant: defendant)
  end

  def jurisdiction_type
    @jurisdiction_type ||= hearing[:hearing][:jurisdictionType]
  end

  def shared_time
    @shared_time ||= hearing[:sharedTime]
  end

  attr_reader :hearing
end
