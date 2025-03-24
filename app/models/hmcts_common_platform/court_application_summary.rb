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

    def to_json(*_args)
      # Warning: this `to_json` method doesn't return JSON, it returns a hash.
      # This is to be consistent with other models in this repo
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |summary|
        summary.application_id application_id
        summary.application_reference application_reference
        summary.application_status application_status
        summary.application_title application_title
        summary.application_type application_type
        summary.received_date received_date
        summary.case_summary case_summary
        summary.hearing_summary hearing_summary
        summary.subject_summary subject_summary
      end
    end
  end
end
