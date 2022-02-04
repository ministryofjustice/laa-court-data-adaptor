module Api
  module External
    module V2
      class ProsecutionConclusionsController < ApplicationController
        def create
          enforce_contract!

          prosecution_conclusion_params["prosecutionConcluded"].map do |pc|
            laa_reference = LaaReference.find_by(defendant_id: pc["defendantId"], linked: true)

            next if laa_reference.blank?

            Sqs::MessagePublisher.call(
              message: pc.to_h.merge("maatId" => laa_reference.maat_reference),
              queue_url: Rails.configuration.x.aws.sqs_url_prosecution_concluded,
            )
          end

          head :accepted
        end

      private

        def enforce_contract!
          unless contract.success?
            message = "Prosecution conclusion contract failed with: #{contract.errors.to_hash}"
            raise Errors::ContractError, message
          end
        end

        def contract
          ProsecutionConclusionContract.new.call(prosecution_conclusion_params.to_hash)
        end

        def prosecution_conclusion_params
          params.require(:prosecution_conclusion).permit(
            prosecutionConcluded: [
              :prosecutionCaseId,
              :defendantId,
              :isConcluded,
              :hearingIdWhereChangeOccurred,
              {
                offenceSummary: [
                  :offenceId,
                  :offenceCode,
                  :proceedingsConcluded,
                  :proceedingsConcludedChangedDate,
                  {
                    plea: %i[
                      originatingHearingId
                      value
                      pleaDate
                    ],
                    verdict: [
                      :verdictDate,
                      :originatingHearingId,
                      {
                        verdictType: %i[
                          description
                          category
                          categoryType
                          sequence
                          verdictTypeId
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          )
        end
      end
    end
  end
end
