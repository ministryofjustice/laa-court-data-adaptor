# frozen_string_literal: true

class UnlinkDefendantContract < Dry::Validation::Contract
  UUID_REGEXP = /\A[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}\z/.freeze

  params do
    required(:defendant_id).filled(:str?, size?: 36, format?: UUID_REGEXP)
  end
end
