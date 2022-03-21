class ProsecutionConclusionContract < Dry::Validation::Contract
  json do
    required(:prosecutionConcluded).array(:hash) do
      required(:prosecutionCaseId).value(:string)
      required(:defendantId).value(:string)
      required(:isConcluded).value(:bool)
      required(:hearingIdWhereChangeOccurred).value(:string)

      required(:offenceSummary).array(:hash) do
        required(:offenceId).value(:string)
        required(:offenceCode).value(:string)
        required(:proceedingsConcluded).value(:bool)
        optional(:proceedingsConcludedChangedDate).value(:string)

        optional(:plea).value(:hash) do
          required(:originatingHearingId).value(:string)
          required(:value).value(:string)
          required(:pleaDate).value(:string)
        end

        optional(:verdict).value(:hash) do
          required(:verdictDate).value(:string)
          required(:originatingHearingId).value(:string)

          required(:verdictType).value(:hash) do
            required(:description).value(:string)
            required(:category).value(:string)
            required(:categoryType).value(:string)
            required(:sequence).value(:integer)
            required(:verdictTypeId).value(:string)
          end
        end
      end
    end
  end
end
