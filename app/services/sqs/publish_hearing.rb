# frozen_string_literal: true

module Sqs
  class PublishHearing < ApplicationService
    attr_reader :shared_time, :hearing_data, :case_urn, :defendant, :appeal_data, :court_application, :function_type

    def initialize(shared_time:,
                   hearing_data:,
                   case_urn:,
                   defendant:,
                   appeal_data:,
                   court_application:,
                   function_type:)
      @shared_time = shared_time
      @hearing_data = hearing_data
      @case_urn = case_urn
      @defendant = defendant
      @appeal_data = appeal_data
      @court_application = court_application
      @function_type = function_type
    end

    def call
      MessagePublisher.call(message: message, queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted)
    end

  private

    def message
      if @function_type == "OFFENCE"
        {
          maatId: laa_reference.maat_reference.to_i,
          caseUrn: case_urn,
          jurisdictionType: jurisdiction_type,
          asn: defendant.dig(:personDefendant, :arrestSummonsNumber),
          cjsAreaCode: cjs_area_code,
          caseCreationDate: shared_time.to_date.strftime("%Y-%m-%d"),
          cjsLocation: cjs_location,
          docLanguage: "EN",
          proceedingsConcluded: defendant.dig(:proceedingsConcluded),
          inActive: inactive?,
          function_type: function_type,
          defendant: defendant_hash,
          session: session_hash,
          ccOutComeData: crown_court_outcome_hash,
        }
      elsif @function_type == "APPLICATION"
        {
          maatId: laa_reference.maat_reference.to_i,
          caseUrn: court_application[:applicationReference],
          jurisdictionType: jurisdiction_type,
          asn: court_application[:defendantASN],
          cjsAreaCode: cjs_area_code,
          caseCreationDate: shared_time.to_date.strftime("%Y-%m-%d"),
          cjsLocation: cjs_location,
          docLanguage: "EN",
          inActive: true,
          function_type: function_type,
          defendant: defendant_hash,
          session: session_hash,
        }
      end
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

    def court_application_type
      court_application[:type]
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
      if function_type == "OFFENCE"
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
            [:results, judicial_results_map(offence[:judicialResults])],
            [:plea, offence[:plea]],
            [:verdict, format_verdict(offence[:verdict])],
          ].to_h
        end

      elsif function_type == "APPLICATION"
        {
          offenceId: court_application_type[:id],
          offenceCode: court_application_type[:code],
          offenceShortTitle: court_application_type[:type],
          offenceClassification: court_application_type[:categoryCode],
          offenceDate: court_application[:applicationReceivedDate],
          offenceWording: court_application_type[:legislation],
          results: judicial_results_map(court_application[:judicialResults]),
        }
      end
    end

    def judicial_results_map(judicial_results)
      if function_type == "OFFENCE"
        judicial_results&.map do |result|
          [
            [:resultCode, result[:cjsCode]],
            [:resultShortTitle, result[:label]],
            [:resultText, result[:resultText]],
            [:resultCodeQualifiers, result[:qualifier]],
            [:nextHearingDate, result.dig(:nextHearing, :listedStartDateTime)&.to_date&.strftime("%Y-%m-%d")],
            [:nextHearingLocation, hearing_location(result.dig(:nextHearing, :courtCentre, :id))],
            [:laaOfficeAccount, defendant&.dig(:defenceOrganisation, :laaAccountNumber)],
            [:legalAidWithdrawalDate, defendant&.dig(:laaApplnReference, :effectiveEndDate)],
          ].to_h
        end
      elsif function_type == "APPLICATION"
        judicial_results&.map do |result|
          {
            resultCode: result[:cjsCode],
            resultShortTitle: result[:label],
            resultText: result[:resultText],
            resultCodeQualifiers: result[:qualifier],
            nextHearingDate: result.dig(:nextHearing, :listedStartDateTime)&.to_date&.strftime("%Y-%m-%d"),
            nextHearingLocation: result.dig(:nextHearing, :courtCentre, :code),
          }
        end

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
      if function_type == "OFFENCE"
        {
          courtLocation: cjs_location,
          dateOfHearing: defendant.dig(:offences, 0, :judicialResults, 0, :orderedDate),
          postHearingCustody: PostHearingCustodyCalculator.call(offences: defendant[:offences]),
          sessionValidateDate: defendant.dig(:offences, 0, :judicialResults, 0, :orderedDate),
        }
      elsif function_type == "APPLICATION"
        {
          courtLocation: cjs_location,
          dateOfHearing: court_application[:judicialResults][0][:orderedDate], # Question outstanding what this should be
          sessionValidateDate: hearing_data.dig(:hearing_days, 0, :sittingDay),
        }
      end
    end

    def crown_court_outcome_hash
      CrownCourtOutcomeCreator.call(defendant: defendant, appeal_data: appeal_data) if jurisdiction_type == "CROWN" && result_is_a_conclusion?
    end

    def result_is_a_conclusion?
      defendant[:offences]&.any? { |offence| offence[:verdict].present? } || appeal_data.present?
    end

    def laa_reference
      LaaReference.find_by!(defendant_id: defendant[:id], linked: true)
    end

    def jurisdiction_type
      hearing_data[:jurisdiction_type]
    end

    def court_centre
      HmctsCommonPlatform::Reference::CourtCentre.find(hearing_data[:court_centre_id])
    end
  end
end
