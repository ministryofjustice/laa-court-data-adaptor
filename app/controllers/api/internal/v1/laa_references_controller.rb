# frozen_string_literal: true

module Api
  module Internal
    module V1
      class LaaReferencesController < ApplicationController
        def create
          contract = LaaReferenceCreator.call(**transformed_params)
          if contract.errors.present?
            render json: contract.errors.to_hash, status: :bad_request
          else
            make_common_platform_calls(contract)

            render status: :accepted
          end
        end

        private

        def create_params
          params.from_jsonapi.require(:laa_reference).permit(allowed_params)
        end

        def allowed_params
          %i[maat_reference defendant_id]
        end

        def transformed_params
          create_params.slice(*allowed_params).to_hash.transform_keys(&:to_sym)
        end

        def make_common_platform_calls(contract)
          maat_reference = contract[:maat_reference]
          defendant_id = contract[:defendant_id]
          offences = ProsecutionCaseDefendantOffence.where(defendant_id: defendant_id)
          prosecution_case_id = offences.pluck(:prosecution_case_id).first
          offence_ids = offences.pluck(:offence_id)

          offence_ids.each do |offence_id|
            LaaReferenceUpdaterJob.perform_later(
              prosecution_case_id: prosecution_case_id,
              defendant_id: defendant_id,
              offence_id: offence_id,
              status_code: 'AP',
              application_reference: maat_reference,
              status_date: Date.today.strftime('%Y-%m-%d')
            )
          end
        end
      end
    end
  end
end
