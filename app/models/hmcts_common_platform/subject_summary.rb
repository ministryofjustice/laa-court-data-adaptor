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

    def to_json(*_args)
      # Warning: this `to_json` method doesn't return JSON, it returns a hash.
      # This is to be consistent with other models in this repo
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |summary|
        summary.proceedings_concluded proceedings_concluded
        summary.subject_id subject_id
        summary.master_defendant_id master_defendant_id
        summary.defendant_asn defendant_asn
        summary.organisation_name organisation_name
        summary.representation_order representation_order
        summary.offence_summary offence_summary
      end
    end
  end
end
