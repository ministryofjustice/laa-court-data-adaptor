module Api
  module External
    module V2
      class ProsecutionConclusionsController < ApplicationController
        def create
          enforce_contract!

          Sqs::MessagePublisher.call(
            message: prosecution_conclusion_params,
            queue_url: Rails.configuration.x.aws.sqs_url_prosecution_concluded,
          )

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
              :hearingIdWhereChangeOccured,
              {
                concludedOffenceSummary: [
                  :offenceId,
                  :offenceCode,
                  :proceedingsConcluded,
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
