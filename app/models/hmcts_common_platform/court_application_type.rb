module HmctsCommonPlatform
  class CourtApplicationType
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def description
      data[:type]
    end

    def code
      data[:code]
    end

    def category_code
      data[:categoryCode]
    end

    def legislation
      data[:legislation]
    end

    def applicant_appellant_flag
      data[:applicantAppellantFlag]
    end

    def link_type
      data[:linkType]
    end

    def jurisdiction
      data[:jurisdiction]
    end

    def appeal_flag
      data[:appealFlag]
    end

    def plea_applicable_flag
      data[:pleaApplicableFlag]
    end

    def summons_template_type
      data[:summonsTemplateType]
    end

    def valid_from
      data[:validFrom]
    end

    def valid_to
      data[:validTo]
    end

    def offence_active_order
      data[:offenceActiveOrder]
    end

    def commr_of_oath_flag
      data[:commrOfOathFlag]
    end

    def breach_type
      data[:breachType]
    end

    def court_of_appeal_flag
      data[:courtOfAppealFlag]
    end

    def court_extract_avl_flag
      data[:courtExtractAvlFlag]
    end

    def listing_notif_template
      data[:listingNotifTemplate]
    end

    def boxwork_notif_template
      data[:boxworkNotifTemplate]
    end

    def prosecutor_third_party_flag
      data[:prosecutorThirdPartyFlag]
    end

    def spi_out_applicable_flag
      data[:spiOutApplicableFlag]
    end

    def hearing_code
      data[:hearingCode]
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |court_application_type|
        court_application_type.id id
        court_application_type.description description
        court_application_type.code code
        court_application_type.category_code category_code
        court_application_type.legislation legislation
        court_application_type.applicant_appellant_flag applicant_appellant_flag
        court_application_type.link_type link_type
        court_application_type.jurisdiction jurisdiction
        court_application_type.appeal_flag appeal_flag
        court_application_type.plea_applicable_flag plea_applicable_flag
        court_application_type.summons_template_type summons_template_type
        court_application_type.valid_from valid_from
        court_application_type.valid_to valid_to
        court_application_type.offence_active_order offence_active_order
        court_application_type.commr_of_oath_flag commr_of_oath_flag
        court_application_type.breach_type breach_type
        court_application_type.court_of_appeal_flag court_of_appeal_flag
        court_application_type.court_extract_avl_flag court_extract_avl_flag
        court_application_type.listing_notif_template listing_notif_template
        court_application_type.boxwork_notif_template boxwork_notif_template
        court_application_type.prosecutor_third_party_flag prosecutor_third_party_flag
        court_application_type.spi_out_applicable_flag spi_out_applicable_flag
        court_application_type.hearing_code hearing_code
      end
    end
  end
end
