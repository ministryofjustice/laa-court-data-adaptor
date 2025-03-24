module HmctsCommonPlatform
  class CourtApplicationSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def application_id
      data[:applicationId]
    end

    def application_reference
      data[:applicationReference]
    end

    def application_status
      data[:applicationStatus]
    end

    def application_title
      data[:applicationTitle]
    end

    def application_type
      data[:applicationType]
    end

    def received_date
      data[:receivedDate]
    end

    def case_summary
      data[:caseSummary]&.map do |summary_object|
        HmctsCommonPlatform::CaseSummary.new(summary_object)
      end
    end

    def hearing_summary
      data[:hearingSummary]&.map do |summary_object|
        HmctsCommonPlatform::HearingSummary.new(summary_object)
      end
    end

    def subject_summary
      data[:subjectSummary]&.map do |summary_object|
        HmctsCommonPlatform::SubjectSummary.new(summary_object)
      end
    end

    def as_json
      {
        application_id:,
        application_reference:,
        application_status:,
        application_title:,
        application_type:,
        received_date:,
        case_summary: case_summary.as_json,
        hearing_summary: hearing_summary.as_json,
        subject_summary: subject_summary.as_json,
      }
    end
  end
end
