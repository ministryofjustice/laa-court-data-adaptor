# frozen_string_literal: true

module CommonPlatform
  class PostcodeValidator < ApplicationService
    def initialize(postcode:)
      @postcode = postcode
    end

    def call
      JSON::Validator.validate(schema, postcode, validate_schema: true)
    end

  private

    attr_reader :postcode
    def schema
      {
        "description": "UK Gov post code validation following CJS Data Standards",
        "type": "string",
        "pattern": "^(([gG][iI][rR] {0,}0[aA]{2})|(([aA][sS][cC][nN]|[sS][tT][hH][lL]|[tT][dD][cC][uU]|[bB][bB][nN][dD]|[bB][iI][qQ][qQ]|[fF][iI][qQ][qQ]|[pP][cC][rR][nN]|[sS][iI][qQ][qQ]|[iT][kK][cC][aA]) {0,}1[zZ]{2})|((([a-pr-uwyzA-PR-UWYZ][a-hk-yxA-HK-XY]?[0-9][0-9]?)|(([a-pr-uwyzA-PR-UWYZ][0-9][a-hjkstuwA-HJKSTUW])|([a-pr-uwyzA-PR-UWYZ][a-hk-yA-HK-Y][0-9][abehmnprv-yABEHMNPRV-Y]))) [0-9][abd-hjlnp-uw-zABD-HJLNP-UW-Z]{2}))$",
        "maxLength": 8,
      }
    end
  end
end
