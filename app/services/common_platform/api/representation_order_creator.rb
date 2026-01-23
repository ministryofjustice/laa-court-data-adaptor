# frozen_string_literal: true

module CommonPlatform
  module Api
    class RepresentationOrderCreator < ApplicationService
      # This creates representation orders for Appeal, Breach and POCA applications
      # via Common Platform API
      # Input:
      #   defendant_id
      #   offences: [offence_id, status_code, status_date, effective_start_date, effective_end_date]
      #   maat_reference
      #   defence_organisation
      def initialize(defendant_id:, offences:, maat_reference:, defence_organisation:)
        @offences = offences.map { |offence|
          offence.symbolize_keys
                 .slice(:offence_id,
                        :status_code,
                        :status_date,
                        :effective_start_date,
                        :effective_end_date)
        }.reject { |offence| offence[:status_date].blank? }

        @maat_reference = maat_reference
        @defendant_id = defendant_id
        @defence_organisation = defence_organisation.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
        sanitise_defence_organisation
      end

      def call
        call_common_platform_endpoint
      end

    private

      attr_reader :defendant_id, :offences, :maat_reference, :defence_organisation, :contact

      def call_common_platform_endpoint
        court_application = CourtApplication.find_by(subject_id: defendant_id)
        if court_application.present?
          record_court_application_representation_order(court_application)
        else
          record_prosecution_case_representation_order
        end
      end

      def record_court_application_representation_order(court_application)
        if court_application.appeal?
          offences.each do |offence|
            params = offence.merge(
              court_application_id: court_application.id,
              subject_id: defendant_id,
              application_reference: maat_reference,
              defence_organisation:,
            )

            # Call CP API /prosecutionCases/representationOrder/applications/.../subject/.../offences/...
            CommonPlatform::Api::RecordApplicationRepresentationOrderForAppeal.call(**params)
          end
        else
          offence = offences.first    # Breach or POCA contains only a Dummy offence
          offence.delete(:offence_id) # Dummy id, not required for this call

          params = offence.merge(
            court_application_id: court_application.id,
            application_reference: maat_reference,
            defence_organisation:,
          )

          # Call CP API /prosecutionCases/representationOrder/applications/...
          CommonPlatform::Api::RecordApplicationRepresentationOrderForBreach.call(**params.deep_symbolize_keys)
        end
      end

      def record_prosecution_case_representation_order
        offences_with_case_defendant_offences.each do |offence, case_defendant_offence|
          params = offence.merge(
            case_defendant_offence:,
            defendant_id:,
            defence_organisation:,
            application_reference: maat_reference,
          )

          # Call CP API /prosecutionCases/representationOrder/cases/.../defendants/.../offences/...
          CommonPlatform::Api::RecordProsecutionCaseRepresentationOrder.call(**params.deep_symbolize_keys)
        end
      end

      def offences_with_case_defendant_offences
        offences.map { |offence|
          [offence, ProsecutionCaseDefendantOffence.find_by(defendant_id:, offence_id: offence[:offence_id])]
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
    end
  end
end
