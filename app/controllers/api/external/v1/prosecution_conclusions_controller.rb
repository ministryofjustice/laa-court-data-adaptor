module Api
  module External
    module V1
      class ProsecutionConclusionsController < ApplicationController
        def create
          log_payload
          enforce_contract!

          prosecution_conclusion_params["prosecutionConcluded"].each do |pc|
            laa_reference = get_linked_laa_reference(pc)

            next unless laa_reference

            Sqs::MessagePublisher.call(
              message: pc.to_h.merge("maatId" => laa_reference.maat_reference),
              queue_url: Rails.configuration.x.aws.sqs_url_prosecution_concluded,
              log_info: { maat_reference: laa_reference.maat_reference },
            )
          end

          head :accepted
        end

      private

        def enforce_contract!
          unless contract.success?
            raise Errors::ContractError.new(contract, "Prosecution conclusion contract")
          end
        end

        def contract
          ProsecutionConclusionContract.new.call(prosecution_conclusion_params.to_hash)
        end

        def get_linked_laa_reference(param_set)
          defendant_id = param_set["defendantId"] || param_set.dig("applicationConcluded", "subjectId")
          LaaReference.find_by(defendant_id:, linked: true)
        end

        def prosecution_conclusion_params
          params.require(:prosecution_conclusion).permit!
        end
      end
    end
  end
end
