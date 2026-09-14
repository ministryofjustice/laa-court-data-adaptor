# frozen_string_literal: true

RSpec.describe Errors, type: :model do
  describe Errors::ContractError do
    subject(:error) { described_class.new(contract, "Representation Order contract") }

    let(:contract) do
      instance_double(
        Dry::Validation::Result,
        errors: message_set,
      )
    end

    let(:messages) do
      [
        Dry::Validation::Message.new("is missing", path: %i[first_name], meta: {}),
        Dry::Validation::Message.new("is invalid", path: %i[address street], meta: {}),
      ]
    end

    let(:message_set) do
      Dry::Validation::MessageSet.new(messages, {})
    end

    it "preserves the legacy message format for clients" do
      expect(error.message).to eq(
        "Representation Order contract failed with: {first_name: [\"is missing\"], address: {street: [\"is invalid\"]}}",
      )
    end

    it "exposes contract validation error codes" do
      expect(error.codes).to eq(%w[first_name_contract_failure addressstreet_contract_failure])
    end
  end

  describe Errors::DefendantError do
    it "wraps a single code in an array" do
      error = described_class.new("Defendant ID 123 found in multiple prosecution cases", "multiple_matches")

      expect(error.message).to eq("Defendant ID 123 found in multiple prosecution cases")
      expect(error.codes).to eq(%w[multiple_matches])
    end

    it "preserves an array of codes" do
      error = described_class.new("Defendant ID 123 found in multiple prosecution cases", %w[multiple_matches case_not_found])

      expect(error.codes).to eq(%w[multiple_matches case_not_found])
    end
  end
end
