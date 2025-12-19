# frozen_string_literal: true

class SupportedCourtApplicationTypes
  CONFIG_PATH = Rails.root.join("lib/supported_court_application_types.yaml").freeze

  class << self
    def get_by_code(code)
      supported_types.find { |type| type["codes"].include?(code) }
    end

    def get_category_by_code(code)
      get_by_code(code)&.dig("category")
    end

  private

    def supported_types
      @supported_types ||= YAML.load_file(CONFIG_PATH)
    end
  end
end
