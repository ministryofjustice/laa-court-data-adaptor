module HmctsCommonPlatform
  class Hearing
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def jurisdiction_type
      data[:jurisdictionType]
    end

    def court_centre_id
      data.dig(:courtCentre, :id)
    end

    def first_sitting_day_date
      data.dig(:hearingDays, 0, :sittingDay)
    end

    def has_shared_results
      data[:hasSharedResults]
    end

    def language
      data[:hearingLanguage]
    end

    def hearing_days
      Array(data[:hearingDays]).map do |hearing_day_data|
        HmctsCommonPlatform::HearingDay.new(hearing_day_data)
      end
    end

    def prosecution_cases
      Array(data[:prosecutionCases]).map do |prosecution_case_data|
        HmctsCommonPlatform::ProsecutionCase.new(prosecution_case_data)
      end
    end

    def court_applications
      Array(data[:courtApplications]).map do |court_application_data|
        HmctsCommonPlatform::CourtApplication.new(court_application_data)
      end
    end

    def court_centre
      HmctsCommonPlatform::CourtCentre.new(data[:courtCentre])
    end

    def hearing_type
      HmctsCommonPlatform::HearingType.new(data[:type])
    end

    def judicial_roles
      Array(data[:judiciary]).map do |judiciary_data|
        HmctsCommonPlatform::JudicialRole.new(judiciary_data)
      end
    end

    def prosecution_counsels
      Array(data[:prosecutionCounsels]).map do |prosecution_counsel_data|
        HmctsCommonPlatform::ProsecutionCounsel.new(prosecution_counsel_data)
      end
    end

    def defence_counsels
      Array(data[:defenceCounsels]).map do |defence_counsel_data|
        HmctsCommonPlatform::DefenceCounsel.new(defence_counsel_data)
      end
    end

    def defendant_judicial_results
      Array(data[:defendantJudicialResults]).map do |defendant_judicial_result_data|
        HmctsCommonPlatform::DefendantJudicialResult.new(defendant_judicial_result_data)
      end
    end

    def cracked_ineffective_trial
      HmctsCommonPlatform::CrackedIneffectiveTrial.new(data[:crackedIneffectiveTrial])
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |hearing|
        hearing.id id
        hearing.jurisdiction_type jurisdiction_type
        hearing.court_centre court_centre.to_json
        hearing.hearing_language language
        hearing.prosecution_cases prosecution_cases.map(&:to_json)
        hearing.defendant_judicial_results defendant_judicial_results.map(&:to_json)
        hearing.has_shared_results has_shared_results
        hearing.court_applications court_applications.map(&:to_json)
        hearing.hearing_type hearing_type.to_json
        hearing.hearing_days hearing_days.map(&:to_json)
        hearing.judiciary judicial_roles.map(&:to_json)
        hearing.prosecution_counsels prosecution_counsels.map(&:to_json)
        hearing.defence_counsels defence_counsels.map(&:to_json)
        hearing.cracked_ineffective_trial cracked_ineffective_trial.to_json
      end
    end
  end
end
