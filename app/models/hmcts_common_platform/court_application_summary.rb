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
      if data[:judicialResults]
        data[:judicialResults].map { HmctsCommonPlatform::JudicialResult.new(it) }
      elsif application_category.in?(%w[breach poca])
        latest_hearing_judicial_results
      end
    end

    def subject_summary
      @subject_summary ||= HmctsCommonPlatform::SubjectSummary.new(data[:subjectSummary], self)
    end

    def linked_maat_id
      ::LaaReference.find_by(defendant_id: subject_summary.subject_id, linked: true)&.maat_reference
    end

    def to_json(*_args)
      # Warning: this `to_json` method doesn't return JSON, it returns a hash.
      # This is to be consistent with other models in this repo
      to_builder.attributes!
    end

    def category_supported?
      if ENV["BREACH_COURT_APPLICATIONS"] == "true"
        application_category.present?
      else
        application_category == "appeal"
      end
    end

    def application_category
      ::CourtApplication.supported_court_application_types.dig(application_type, "category")
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

    def latest_hearing_judicial_results
      return [] unless latest_hearing

      latest_hearing.defendant_judicial_results.map(&:judicial_result)
    end

    def latest_hearing
      @latest_hearing ||= begin
        hearing_id = hearing_summary.max_by { it.hearing_days.map(&:sitting_day).map(&:to_date).max }&.id
        if hearing_id
          hearing_result_data = CommonPlatform::Api::GetHearingResults.call(hearing_id:)
          hearing_result = HmctsCommonPlatform::HearingResulted.new(hearing_result_data)
          hearing_result.hearing if hearing_result.present?
        end
      end
    end
  end
end
