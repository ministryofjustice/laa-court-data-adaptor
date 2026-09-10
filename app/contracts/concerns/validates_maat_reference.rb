module ValidatesMaatReference
  extend ActiveSupport::Concern
  ALREADY_LINKED_MESSAGE_FROM_MAAT = "is already linked to a case".freeze

  included do
    option :maat_reference_validator, default: -> { MaatApi::MaatReferenceValidator }

    rule(:maat_reference) do
      next unless value

      validation = maat_reference_validator.call(maat_reference: value)
      next if validation.nil? || validation.success?

      message = validation.body["message"]
      key.failure(text: message, code: maat_reference_error_code(message))
    end

  private

    def maat_reference_error_code(message)
      message.include?(ALREADY_LINKED_MESSAGE_FROM_MAAT) ? :maat_reference_already_linked : nil
    end
  end
end
