# frozen_string_literal: true

module Sqs
  class PublishLaaReference < ApplicationService
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
      prosecution_case.body["caseStatus"] == "ACTIVE"
    end

    def message
      {
        maatId: maat_reference,
        caseUrn: prosecution_case.prosecution_case_reference,
        asn: defendant.arrest_summons_number,
        cjsAreaCode: correct_hearing_summary.oucode_l2_code,
        createdUser: user_name,
        cjsLocation: correct_hearing_summary.short_oucode,
        docLanguage: "EN",
        isActive: active?,
        defendant: defendant_hash,
        sessions: sessions_map,
      }
    end

    def defendant_hash
      {
        defendantId: defendant.id,
        forename: defendant.first_name,
        surname: defendant.last_name,
        dateOfBirth: defendant.date_of_birth,
        nino: defendant.national_insurance_number,
        offences: offences_map,
      }
    end

    def offences_map
      defendant.offences.map do |offence|
        [
          [:offenceId, offence.id],
          [:offenceCode, offence.code],
          [:asnSeq, offence.order_index],
          [:offenceClassification, offence.mode_of_trial],
          [:offenceDate, offence.body["startDate"]],
          [:offenceShortTitle, offence.title],
          [:offenceWording, offence.body["wording"]],
        ].to_h
      end
    end

    def sessions_map
      prosecution_case.hearing_summaries.map do |hearing_summary|
        {
          courtLocation: hearing_summary.short_oucode,
          dateOfHearing: hearing_summary.hearing_days.max.to_date.strftime("%Y-%m-%d"),
        }
      end
    end

    def correct_hearing_summary
      return prosecution_case.hearing_summaries.max_by(&:hearing_days) if all_hearings_in_past?
      return prosecution_case.hearing_summaries.min_by(&:hearing_days) if all_hearings_in_future?

      prosecution_case.hearing_summaries.reject(&:hearing_in_future?).max_by(&:hearing_days)
    end

    def all_hearings_in_past?
      prosecution_case.hearing_summaries.all?(&:hearing_in_past?)
    end

    def all_hearings_in_future?
      prosecution_case.hearing_summaries.all?(&:hearing_in_future?)
    end

    attr_reader :prosecution_case, :defendant, :user_name, :maat_reference
  end
end
