# frozen_string_literal: true

module Sqs
  # rubocop:disable Metrics/ClassLength
  class PublishHearing < ApplicationService
    def initialize(shared_time:, jurisdiction_type:, case_urn:, defendant:, cjs_location:)
      @shared_time = shared_time
      @jurisdiction_type = jurisdiction_type
      @case_urn = case_urn
      @defendant = defendant
      @cjs_location = cjs_location
    end

    def call
      MessagePublisher.call(message: message, queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted)
    end

    private

    def inactive?
      jurisdiction_type == 'MAGISTRATES' ? 'N' : 'Y'
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

    def split_name
      defendant_details&.dig(:defendantName)&.split(' ')
    end

    def forename
      split_name&.first
    end

    def surname
      split_name&.last
    end

    def post_hearing_custody
      defendant[:offences].dig(0, :judicialResults, 0, :judicialResultPrompts)&.each do |prompt|
        @post_hearing_custody = prompt[:value] if prompt[:label] == 'Remand Status'
      end

      @post_hearing_custody
    end

    def cjs_area_code
      cjs_location[1, 2] if cjs_location
    end

    def message
      {
        maatId: defendant.dig(:laaApplnReference, :applicationReference).to_i,
        caseUrn: case_urn,
        jurisdictionType: jurisdiction_type,
        asn: defendant.dig(:personDefendant, :arrestSummonsNumber),
        cjsAreaCode: cjs_area_code,
        caseCreationDate: shared_time.split.first,
        cjsLocation: cjs_location,
        docLanguage: 'EN',
        inActive: inactive?,
        defendant: defendant_hash,
        session: session_hash,
        ccOutComeData: crown_court_outcome_hash
      }
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def defendant_hash
      {
        forename: forename,
        surname: surname,
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
        offences: offences_map
      }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def offences_map
      defendant&.dig(:offences)&.map do |offence|
        [
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
          [:results, results_map(offence[:judicialResults])]
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
          [:nextHearingDate, result.dig(:nextHearing, :listedStartDateTime)],
          [:nextHearingLocation, result.dig(:nextHearing, :courtCentre, :ouCode)],
          [:laaOfficeAccount, defendant.dig(:defenceOrganisation, :laaAccountNumber)],
          [:legalAidWithdrawalDate, defendant.dig(:laaApplnReference, :effectiveEndDate)]
        ].to_h
      end
    end

    def session_hash
      {
        courtLocation: cjs_location,
        dateOfHearing: defendant.dig(:offences, 0, :judicialResults, 0, :orderedDate),
        postHearingCustody: post_hearing_custody,
        sessionValidateDate: defendant.dig(:offences, 0, :judicialResults, 0, :orderedDate)
      }
    end

    def crown_court_outcome_hash
      CrownCourtOutcomeCreator.call(defendant: defendant)
    end

    attr_reader :shared_time, :jurisdiction_type, :case_urn, :defendant, :cjs_location
  end
  # rubocop:enable Metrics/ClassLength
end
