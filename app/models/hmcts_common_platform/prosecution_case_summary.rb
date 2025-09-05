module HmctsCommonPlatform
  class ProsecutionCaseSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def prosecution_case_reference
      data[:prosecutionCaseReference]
    end

    def case_status
      data[:caseStatus]
    end

    def defendant_summary(defendant_id)
      defendant_summaries.find { it.defendant_id == defendant_id }
    end

    def defendant_summaries
      Array(data[:defendantSummary]).map do |defendant_summary_data|
        HmctsCommonPlatform::DefendantSummary.new(defendant_summary_data, court_application_summaries)
      end
    end

    def hearing_summaries
      Array(data[:hearingSummary]).map do |hearing_summary_data|
        HmctsCommonPlatform::HearingSummary.new(hearing_summary_data)
      end
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |case_summary|
        case_summary.prosecution_case_reference prosecution_case_reference
        case_summary.case_status case_status
        case_summary.defendant_summaries defendant_summaries.map(&:to_json)
        case_summary.hearing_summaries hearing_summaries.map(&:to_json)
      end
    end

    # TODO: When appeals v2 is switched on we should delete this as we are moving
    # away from matching based on title and this part of the payload will never be read.
    def court_application_summaries
      return [] unless data[:applicationSummary].is_a?(Array)

      @court_application_summaries ||= data[:applicationSummary].select do |summary|
        ::CourtApplication::SUPPORTED_COURT_APPLICATION_TITLES.include?(summary[:applicationTitle])
      end
    end
  end
end
