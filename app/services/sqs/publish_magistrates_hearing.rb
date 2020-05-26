# frozen_string_literal: true

module Sqs
  # rubocop:disable Metrics/ClassLength
  class PublishMagistratesHearing < ApplicationService
    TEMPORARY_CJS_AREA_CODE = 16
    TEMPORARY_CJS_LOCATION = 'B16BG'
    TEMPORARY_OFFENCE_CLASSIFICATION = 'Temporary Offence Classification'
    TEMPORARY_SESSION_VALIDATE_DATE = '2020-01-01'

    def initialize(shared_time:, jurisdiction_type:, case_urn:, defendant:)
      @shared_time = shared_time
      @jurisdiction_type = jurisdiction_type
      @case_urn = case_urn
      @defendant = defendant
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

    def message
      {
        maatId: defendant.dig(:laaApplnReference, :applicationReference).to_i,
        caseUrn: case_urn,
        jurisdictionType: jurisdiction_type,
        asn: defendant.dig(:personDefendant, :arrestSummonsNumber),
        cjsAreaCode: TEMPORARY_CJS_AREA_CODE,
        caseCreationDate: shared_time.split.first,
        cjsLocation: TEMPORARY_CJS_LOCATION,
        docLanguage: 'EN',
        inActive: inactive?,
        defendant: defendant_hash,
        session: session_hash
      }
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def defendant_hash
      {
        forename: forename,
        surname: surname,
        dateOfBirth: defendant_details&.dig(:dateOfBirth),
        address_line1: defendant_address_details&.dig(:address1),
        address_line2: defendant_address_details&.dig(:address2),
        address_line3: defendant_address_details&.dig(:address3),
        address_line4: defendant_address_details&.dig(:address4),
        address_line5: defendant_address_details&.dig(:address5),
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
          [:offenceClassification, TEMPORARY_OFFENCE_CLASSIFICATION],
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
          [:nextHearingLocation, TEMPORARY_CJS_LOCATION],
          [:laaOfficeAccount, defendant.dig(:defenceOrganisation, :laaAccountNumber)],
          [:legalAidWithdrawalDate, defendant.dig(:laaApplnReference, :effectiveEndDate)]
        ].to_h
      end
    end

    def session_hash
      {
        courtLocation: TEMPORARY_CJS_LOCATION,
        dateOfHearing: defendant.dig(:offences, 0, :judicialResults, 0, :orderedDate),
        postHearingCustody: post_hearing_custody,
        sessionValidateDate: TEMPORARY_SESSION_VALIDATE_DATE
      }
    end

    attr_reader :shared_time, :jurisdiction_type, :case_urn, :defendant
  end
  # rubocop:enable Metrics/ClassLength
end
