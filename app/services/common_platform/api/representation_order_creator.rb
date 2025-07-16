# frozen_string_literal: true

module CommonPlatform
  module Api
    class RepresentationOrderCreator < ApplicationService
      def initialize(defendant_id:, offences:, maat_reference:, defence_organisation:)
        @offences = offences.map(&:with_indifferent_access).reject { |offence| offence[:status_date].blank? }
        @maat_reference = maat_reference
        @defendant_id = defendant_id
        @defence_organisation = defence_organisation.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
        sanitise_defence_organisation
      end

      def call
        call_common_platform_endpoint
      end

    private

      def call_common_platform_endpoint
        offences_with_case_defendant_offences.each do |offence, case_defendant_offence|
          application_reference = maat_reference
          offence_id = offence[:offence_id]
          status_code = offence[:status_code]
          status_date = offence[:status_date]
          effective_start_date = offence[:effective_start_date]
          effective_end_date = offence[:effective_end_date]

          if case_defendant_offence.application_type.present?
            CommonPlatform::Api::RecordCourtApplicationRepresentationOrder.call(
              court_application_defendant_offence: case_defendant_offence,
              subject_id: defendant_id,
              offence_id:,
              status_code:,
              application_reference:,
              status_date:,
              effective_start_date:,
              effective_end_date:,
              defence_organisation:,
            )
          else
            CommonPlatform::Api::RecordProsecutionCaseRepresentationOrder.call(
              case_defendant_offence:,
              defendant_id:,
              offence_id:,
              status_code:,
              application_reference:,
              status_date:,
              effective_start_date:,
              effective_end_date:,
              defence_organisation:,
            )
          end
        end
      end

      def offences_with_case_defendant_offences
        offences.map { |offence|
          [offence, LegalCaseDefendantOffence.find_by(defendant_id:, offence_id: offence[:offence_id])]
        }.select { |_offence, case_def| case_def.present? }
      end

      def sanitise_defence_organisation
        sanitise_postcode if defence_organisation.dig(:organisation, :address, :postcode)
        sanitise_contact_details
      end

      def sanitise_postcode
        postcode = defence_organisation.dig(:organisation, :address, :postcode)
        defence_organisation[:organisation][:address].delete(:postcode) unless CommonPlatform::PostcodeValidator.new(postcode:).call
      end

      def sanitise_contact_details
        @contact = defence_organisation.dig(:organisation, :contact)
        return unless contact

        sanitise_email_addresses
        sanitise_phone_numbers
      end

      def sanitise_email_addresses
        %i[primaryEmail secondaryEmail].each do |email|
          defence_organisation[:organisation][:contact].delete(email) unless CommonPlatform::EmailValidator.new(email: contact[email]).call
        end
      end

      def sanitise_phone_numbers
        %i[home mobile].each do |number|
          defence_organisation[:organisation][:contact].delete(number) unless CommonPlatform::PhoneValidator.new(phone: contact[number]).call
        end
      end

      attr_reader :defendant_id, :offences, :maat_reference, :defence_organisation, :contact
    end
  end
end
