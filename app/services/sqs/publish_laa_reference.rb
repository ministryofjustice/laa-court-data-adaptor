# frozen_string_literal: true

module Sqs
  class PublishLaaReference < ApplicationService
    TEMPORARY_CJS_AREA_CODE = 16
    TEMPORARY_CJS_LOCATION = 'B16BG'
    TEMPORARY_DATE_OF_HEARING = '2020-08-16'
    TEMPORARY_POST_HEARING_CUSTODY = 'R'
    TEMPORARY_OFFENCE_CODE = 'AA06035'
    TEMPORARY_MODE_OF_TRIAL = 1
    TEMPORARY_RESULT_CODE = 3026

    def initialize(prosecution_case_id:, defendant_id:, user_name:, maat_reference:)
      @prosecution_case = ProsecutionCase.find(prosecution_case_id)
      @maat_reference = maat_reference
      @user_name = user_name
      @defendant = prosecution_case.defendants.find { |x| x.id == defendant_id }
    end

    def call
      MessagePublisher.call(message: message, queue_url: Rails.configuration.x.aws.sqs_url_link)
    end

    private

    def active?
      prosecution_case.body['caseStatus'] == 'ACTIVE'
    end

    def message
      {
        maatId: maat_reference,
        caseUrn: prosecution_case.prosecution_case_reference,
        asn: defendant.arrest_summons_number,
        cjsAreaCode: TEMPORARY_CJS_AREA_CODE,
        createdUser: user_name,
        cjsLocation: TEMPORARY_CJS_LOCATION,
        docLanguage: 'EN',
        isActive: active?,
        defendant: defendant_hash,
        sessions: sessions_map
      }
    end

    def defendant_hash
      {
        defendantId: defendant.id,
        dateOfBirth: defendant.date_of_birth,
        nino: defendant.national_insurance_number,
        offences: offences_map
      }
    end

    # rubocop:disable Metrics/MethodLength
    def offences_map
      defendant.offences.map do |offence|
        [
          [:offenceId, offence.id],
          [:offenceCode, TEMPORARY_OFFENCE_CODE],
          [:asnSeq, offence.order_index],
          [:offenceShortTitle, offence.title],
          [:offenceWording, offence.body['wording']],
          [:modeOfTrial, TEMPORARY_MODE_OF_TRIAL],
          [:results, [
            [
              [:resultCode, TEMPORARY_RESULT_CODE],
              [:asnSeq, offence.order_index]
            ].to_h
          ]]
        ].to_h
      end
    end
    # rubocop:enable Metrics/MethodLength

    def sessions_map
      [{
        courtLocation: TEMPORARY_CJS_LOCATION,
        dateOfHearing: TEMPORARY_DATE_OF_HEARING,
        postHearingCustody: TEMPORARY_POST_HEARING_CUSTODY
      }]
    end

    attr_reader :prosecution_case, :defendant, :user_name, :maat_reference
  end
end
