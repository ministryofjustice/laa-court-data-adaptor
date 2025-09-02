module HmctsCommonPlatform
  class CourtApplicationSummary
    attr_reader :data

    def initialize(data)
      data = JSON.parse(data) if data.is_a?(String)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def application_id
      data[:applicationId]
    end

    def short_id
      data[:laaApplicationShortId]
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

    def application_result
      data[:applicationResult]
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

    def judicial_results
      (data[:judicialResults] || []).map do |result|
        HmctsCommonPlatform::JudicialResult.new(result)
      end
    end

    def subject_summary
      @subject_summary ||= HmctsCommonPlatform::SubjectSummary.new(data[:subjectSummary])
    end

    def linked_maat_id
      ::LaaReference.find_by(defendant_id: subject_summary.subject_id, linked: true)&.maat_reference
    end

    def to_json(*_args)
      # Warning: this `to_json` method doesn't return JSON, it returns a hash.
      # This is to be consistent with other models in this repo
      to_builder.attributes!
    end

    def supported?
      if ENV["NO_OFFENCE_COURT_APPLICATIONS"] == "true"
        application_category.present?
      else
        application_category == :appeal
      end
    end

    def application_category
      ::CourtApplication::SUPPORTED_COURT_APPLICATION_CATEGORIES[application_type]
    end

  private

    def to_builder
      Jbuilder.new do |summary|
        summary.application_id application_id
        summary.short_id short_id
        summary.application_reference application_reference
        summary.application_status application_status
        summary.application_title application_title
        summary.application_type application_type
        summary.application_result application_result
        summary.application_category application_category
        summary.received_date received_date
        summary.case_summary case_summary.map(&:to_json)
        summary.hearing_summary hearing_summary.map(&:to_json)
        summary.subject_summary subject_summary.to_json
        summary.judicial_results judicial_results.map(&:to_json)
        summary.linked_maat_id linked_maat_id
      end
    end
  end
end
