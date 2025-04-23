module HmctsCommonPlatform
  class DefendantSummary
    attr_reader :data, :court_application_summaries

    def initialize(data, court_application_summaries)
      @data = HashWithIndifferentAccess.new(data || {})
      @court_application_summaries = court_application_summaries
      match_application_summaries
    end

    def defendant_id
      data[:defendantId]
    end

    def name
      data[:defendantName]
    end

    def first_name
      data[:defendantFirstName]
    end

    def middle_name
      data[:defendantMiddleName]
    end

    def last_name
      data[:defendantLastName]
    end

    def arrest_summons_number
      data[:defendantASN]
    end

    def date_of_birth
      data[:defendantDOB]
    end

    def national_insurance_number
      data[:defendantNINO]
    end

    def proceedings_concluded
      data[:proceedingsConcluded]
    end

    def representation_order
      HmctsCommonPlatform::RepresentationOrder.new(data[:representationOrder])
    end

    def offence_summaries
      Array(data[:offenceSummary]).map do |offence_summary_data|
        HmctsCommonPlatform::OffenceSummary.new(offence_summary_data)
      end
    end

    def application_summaries
      Array(data[:applicationSummaries]).map do |application_summary|
        HmctsCommonPlatform::DefendantCourtApplicationSummary.new(application_summary)
      end
    end

    def to_json(*_args)
      to_builder.attributes!.compact
    end

  private

    def match_application_summaries
      @data[:applicationSummaries] = []

      return unless court_application_summaries.is_a?(Array) && court_application_summaries.any?

      court_application_summaries.each do |summary|
        first_name = summary.dig("subjectSummary", "defendantFirstName").to_s.strip
        last_name  = summary.dig("subjectSummary", "defendantLastName").to_s.strip

        expected_first_name = data[:defendantFirstName].to_s.strip
        expected_last_name  = data[:defendantLastName].to_s.strip

        next unless first_name == expected_first_name && last_name == expected_last_name

        @data[:applicationSummaries] << summary
      end
    end

    def to_builder
      Jbuilder.new do |defendant_summary|
        defendant_summary.id defendant_id
        defendant_summary.first_name first_name
        defendant_summary.middle_name middle_name
        defendant_summary.last_name last_name
        defendant_summary.name name
        defendant_summary.arrest_summons_number arrest_summons_number
        defendant_summary.date_of_birth date_of_birth
        defendant_summary.national_insurance_number national_insurance_number
        defendant_summary.proceedings_concluded proceedings_concluded
        defendant_summary.representation_order representation_order.to_json
        defendant_summary.offence_summaries(offence_summaries.map(&:to_json))
        defendant_summary.application_summaries(application_summaries.map(&:to_json))
      end
    end
  end
end
