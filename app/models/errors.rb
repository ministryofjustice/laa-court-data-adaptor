module Errors
  class ContractError < StandardError
    def initialize(contract, contract_name)
      # This abomination of a format is how CDA has historically contract validation
      # errors back to clients. We are preserving it here for backwards compatibility,
      # but now also send back an error code which clients can translate into
      # a user-facing string as appropriate
      legacy_message = "#{contract_name} failed with: #{contract.errors.to_hash}"
      super legacy_message
      @contract = contract
    end

    def codes
      @contract.errors.map { |error| "#{error.path.join}_contract_failure" }
    end
  end

  class DefendantError < StandardError
    def initialize(message, code_or_codes)
      super message
      @codes = Array(code_or_codes)
    end

    attr_reader :codes
  end
end
