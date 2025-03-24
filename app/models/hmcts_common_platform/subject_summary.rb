module HmctsCommonPlatform
  class SubjectSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
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

    def defendant_asn
      data[:defendantASN]
    end

    def organisation_name
      data[:organisationName]
    end

    def representation_order
      HmctsCommonPlatform::RepresentationOrder.new(data[:representationOrder])
    end

    def offence_summary
      data[:offenceSummary]&.map do |summary_object|
        HmctsCommonPlatform::OffenceSummary.new(summary_object)
      end
    end

    def as_json
      {
        proceedings_concluded:,
        subject_id:,
        master_defendant_id:,
        defendant_asn:,
        organisation_name:,
        representation_order: representation_order.as_json,
        offence_summary: offence_summary.as_json,
      }
    end
  end
end
