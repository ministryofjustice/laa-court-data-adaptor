module ProsecutionConcludable
  extend ActiveSupport::Concern

  def create
    enforce_contract!

    prosecution_conclusion_params["prosecutionConcluded"].each do |pc|
      laa_reference = retrieve_laa_reference(pc)

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
      message = "Prosecution conclusion contract failed with: #{contract.errors.to_hash}"
      raise Errors::ContractError, message
    end
  end

  def contract
    ProsecutionConclusionContract.new.call(prosecution_conclusion_params.to_hash)
  end

  def retrieve_laa_reference(param_set)
    defendant_id = param_set["defendantId"] || param_set.dig("applicationConcluded", "subjectId")
    LaaReference.find_by(defendant_id:, linked: true)
  end

  def prosecution_conclusion_params
    params.require(:prosecution_conclusion).permit(
      prosecutionConcluded: [
        :prosecutionCaseId,
        :defendantId,
        :isConcluded,
        :hearingIdWhereChangeOccurred,
        {
          applicationConcluded: %i[
            applicationId
            applicationResultCode
            subjectId
          ],
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
