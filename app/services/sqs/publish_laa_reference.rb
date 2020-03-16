# frozen_string_literal: true

module Sqs
  class PublishLaaReference < ApplicationService
    def initialize(prosecution_case_id:, defendant_id:, maat_reference:)
      @prosecution_case = ProsecutionCase.find(prosecution_case_id)
      @maat_reference = maat_reference
      @defendant = prosecution_case.defendants.find { |x| x.id == defendant_id }
    end

    def call
      MessagePublisher.call(message: message)
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
        docLanguage: 'EN',
        isActive: active?,
        defendant: {
          defendantId: defendant.id,
          dateOfBirth: defendant.date_of_birth,
          nino: defendant.national_insurance_number,
          offences: offences_map
        },
        sessions: []
      }
    end

    def offences_map
      defendant.offences.map do |offence|
        [
          [:offenceCode, offence.code],
          [:asnSeq, offence.order_index],
          [:offenceShortTitle, offence.title],
          [:offenceWording, offence.body['wording']],
          [:modeOfTrial, offence.body['modeOfTrial']],
          [:results, [
            [[:asnSeq, offence.order_index]].to_h
          ]]
        ].to_h
      end
    end

    attr_reader :prosecution_case, :defendant, :maat_reference
  end
end
