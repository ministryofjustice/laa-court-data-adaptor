module ValidatesMaatReference
  extend ActiveSupport::Concern
  included do
    option :maat_reference_validator, default: -> { MaatApi::MaatReferenceValidator }

    rule(:maat_reference) do
      next unless value

      validation_result = maat_reference_validator.call(maat_reference: value)
      key.failure(validation_result.error_code) if validation_result.error_code
    end
  end
end
