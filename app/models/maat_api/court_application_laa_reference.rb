module MaatApi
  class CourtApplicationLaaReference
    include RelevantHearingSummaryFindable

    attr_reader :court_application, :user_name, :maat_reference

    def initialize(user_name:, maat_reference:, court_application:)
      @maat_reference = maat_reference
      @user_name = user_name
      @court_application = court_application
    end

    def case_urn
      TODO
    end

    def defendant_asn
      subject_summary.defendant_asn
    end

    def doc_language
      "EN"
    end

    def is_active?
      court_application.case_summary.case_status == "ACTIVE"
    end

    def cjs_location
      relevant_hearing_summary.court_centre_short_oucode
    end

    def cjs_area_code
      relevant_hearing_summary.court_centre_oucode_l2_code
    end

    def defendant
      {
        defendantId: subject_summary.defendant_id,
        forename: subject_summary.first_name,
        surname: subject_summary.last_name,
        dateOfBirth: subject_summary.date_of_birth,
        nino: subject_summary.national_insurance_number,
        offences:,
      }
    end

    def sessions
      hearing_summaries.map do |hearing_summary|
        {
          courtLocation: hearing_summary.court_centre_short_oucode,
          dateOfHearing: hearing_summary.hearing_days.map(&:sitting_day).max&.to_date&.strftime("%Y-%m-%d"),
        }
      end
    end

  private

    def hearing_summaries
      court_application.hearing_summaries.map do |hearing_summary_data|
        HmctsCommonPlatform::HearingSummary.new(hearing_summary_data)
      end
    end

    def subject_summary
      TODO
    end

    def offences
      subject_summary.offence_summaries.map do |offence_summary|
        {
          offenceId: offence_summary.offence_id,
          offenceCode: offence_summary.code,
          asnSeq: offence_summary.order_index,
          offenceClassification: offence_summary.mode_of_trial,
          offenceDate: offence_summary.start_date,
          offenceShortTitle: offence_summary.title,
          offenceWording: offence_summary.wording,
        }
      end
    end
  end
end
