# frozen_string_literal: true

module Sqs
  class PublishHearing < ApplicationService
    def initialize(shared_time:, jurisdiction_type:, case_urn:, defendant:, court_centre_id:, appeal_data:)
      @shared_time = shared_time
      @jurisdiction_type = jurisdiction_type
      @case_urn = case_urn
      @defendant = defendant
      @court_centre = HmctsCommonPlatform::Reference::CourtCentre.find(court_centre_id)
      @appeal_data = appeal_data
      @laa_reference = LaaReference.find_by!(defendant_id: defendant[:id], linked: true)
    end

    def call
      MessagePublisher.call(message: message, queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted)
    end

  private

    def message
      {
        maatId: laa_reference.maat_reference.to_i,
        caseUrn: case_urn,
        jurisdictionType: jurisdiction_type,
        asn: defendant.dig(:personDefendant, :arrestSummonsNumber),
        cjsAreaCode: cjs_area_code,
        caseCreationDate: shared_time.to_date.strftime("%Y-%m-%d"),
        cjsLocation: cjs_location,
        docLanguage: "EN",
        proceedingsConcluded: defendant.dig(:proceedingsConcluded) || false,
        inActive: inactive?,
        defendant: defendant_hash,
        session: session_hash,
      }
    end

    def cjs_area_code
      court_centre.oucode_l2_code
    end

    def cjs_location
      court_centre.short_oucode
    end

    def inactive?
      jurisdiction_type == "MAGISTRATES" ? "N" : "Y"
    end

    def defendant_details
      defendant&.dig(:personDefendant, :personDetails)
    end

    def defendant_address_details
      defendant_details&.dig(:address)
    end

    def defendant_contact_details
      defendant_details&.dig(:contact)
    end

    def defendant_hash
      {
        forename: defendant_details&.dig(:firstName),
        surname: defendant_details&.dig(:lastName),
        dateOfBirth: defendant_details&.dig(:dateOfBirth),
        addressLine1: defendant_address_details&.dig(:address1),
        addressLine2: defendant_address_details&.dig(:address2),
        addressLine3: defendant_address_details&.dig(:address3),
        addressLine4: defendant_address_details&.dig(:address4),
        addressLine5: defendant_address_details&.dig(:address5),
        postcode: defendant_address_details&.dig(:postcode),
        nino: defendant_details&.dig(:nationalInsuranceNumber),
        telephoneHome: defendant_contact_details&.dig(:home),
        telephoneWork: defendant_contact_details&.dig(:work),
        telephoneMobile: defendant_contact_details&.dig(:mobile),
        email1: defendant_contact_details&.dig(:primaryEmail),
        email2: defendant_contact_details&.dig(:secondaryEmail),
        offences: offences_map,
      }
    end

    def offences_map
      defendant&.dig(:offences)&.map do |offence|
        [
          [:offenceId, offence[:id]],
          [:offenceCode, offence[:offenceCode]],
          [:asnSeq, offence[:orderIndex]],
          [:offenceShortTitle, offence[:offenceTitle]],
          [:offenceClassification, offence[:modeOfTrial]],
          [:offenceDate, offence[:startDate]],
          [:offenceWording, offence[:wording]],
          [:modeOfTrial, offence.dig(:allocationDecision, :motReasonCode)],
          [:legalAidStatus, offence.dig(:laaApplnReference, :statusCode)],
          [:legalAidStatusDate, offence.dig(:laaApplnReference, :statusDate)],
          [:legalAidReason, offence.dig(:laaApplnReference, :statusDescription)],
          [:results, results_map(offence[:judicialResults])],
          [:plea, offence[:plea]],
          [:verdict, format_verdict(offence[:verdict])],
        ].to_h
      end
    end

    def results_map(results)
      results&.map do |result|
        [
          [:resultCode, result[:cjsCode]],
          [:resultShortTitle, result[:label]],
          [:resultText, result[:resultText]],
          [:resultCodeQualifiers, result[:qualifier]],
          [:nextHearingDate, result.dig(:nextHearing, :listedStartDateTime)&.to_date&.strftime("%Y-%m-%d")],
          [:nextHearingLocation, hearing_location(result.dig(:nextHearing, :courtCentre, :id))],
          [:laaOfficeAccount, defendant.dig(:defenceOrganisation, :laaAccountNumber)],
          [:legalAidWithdrawalDate, defendant.dig(:laaApplnReference, :effectiveEndDate)],
        ].to_h
      end
    end

    def format_verdict(verdict)
      return if verdict.nil?

      {
        offenceId: verdict[:offenceId],
        verdictDate: verdict[:verdictDate],
        category: verdict.dig(:verdictType, :category),
        categoryType: verdict.dig(:verdictType, :categoryType),
        cjsVerdictCode: verdict.dig(:verdictType, :cjsVerdictCode),
        verdictCode: verdict.dig(:verdictType, :verdictCode),
      }
    end

    def hearing_location(court_centre_id)
      return if court_centre_id.blank?

      location = HmctsCommonPlatform::Reference::CourtCentre.find(court_centre_id)
      location.short_oucode
    end

    def session_hash
      {
        courtLocation: cjs_location,
        dateOfHearing: defendant.dig(:offences, 0, :judicialResults, 0, :orderedDate),
        postHearingCustody: PostHearingCustodyCalculator.call(offences: defendant[:offences]),
        sessionValidateDate: defendant.dig(:offences, 0, :judicialResults, 0, :orderedDate),
      }
    end

    attr_reader :shared_time, :jurisdiction_type, :case_urn, :defendant, :court_centre, :laa_reference
  end
end
