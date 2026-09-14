module ValidatesMaatReference
  extend ActiveSupport::Concern
  ALREADY_LINKED_MESSAGE_FROM_MAAT = "is already linked to a case".freeze
  NO_COMMON_PLATFORM_MESSAGE_FROM_MAAT = "has no common platform data created".freeze

  included do
    option :maat_reference_validator, default: -> { MaatApi::MaatReferenceValidator }

    rule(:maat_reference) do
      next unless value

      validation = maat_reference_validator.call(maat_reference: value)
      next if validation.nil? || validation.success?

      message = validation.body["message"]
      key.failure(maat_reference_error_code(message))
    end

  private

    def maat_reference_error_code(message)
      if message.include?(ALREADY_LINKED_MESSAGE_FROM_MAAT)
        :already_linked
      elsif message.include?(NO_COMMON_PLATFORM_MESSAGE_FROM_MAAT)
        :no_common_platform_data
      else
        :invalid
      end
    end
  end
end
