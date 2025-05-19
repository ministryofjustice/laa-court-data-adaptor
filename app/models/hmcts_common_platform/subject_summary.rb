module HmctsCommonPlatform
  class SubjectSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def date_of_next_hearing
      data[:dateOfNextHearing]
    end

    def defendant_asn
      data[:defendantASN]
    end

    def defendant_dob
      data[:defendantDOB]
    end

    def defendant_first_name
      data[:defendantFirstName]
    end

    def defendant_nino
      data[:defendantNINO]
    end

    def defendant_last_name
      data[:defendantLastName]
    end

    def proceedings_concluded
      data[:proceedingsConcluded]
    end

    def subject_id
      data[:subjectId]
    end

    def master_defendant_id
      data[:masterDefendantId]
    end

    def organisation_name
      data[:organisationName]
    end

    def representation_order
      HmctsCommonPlatform::RepresentationOrder.new(data[:representationOrder])
    end

    def offence_summary
      Array(data[:offenceSummary]).map do |summary_object|
        HmctsCommonPlatform::OffenceSummary.new(summary_object)
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
        summary.subject_id subject_id
        summary.date_of_next_hearing date_of_next_hearing
        summary.defendant_asn defendant_asn
        summary.defendant_dob defendant_dob
        summary.defendant_first_name defendant_first_name
        summary.defendant_last_name defendant_last_name
        summary.master_defendant_id master_defendant_id
        summary.offence_summary offence_summary.map(&:to_json)
        summary.proceedings_concluded proceedings_concluded
        summary.organisation_name organisation_name
        summary.representation_order representation_order.to_json
      end
    end
  end
end
