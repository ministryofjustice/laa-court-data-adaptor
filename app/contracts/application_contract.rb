class ApplicationContract < Dry::Validation::Contract
  config.messages.backend = :i18n
  config.messages.top_namespace = :validation
  config.messages.load_paths << Rails.root.join("config/locales/validation.en.yml")
end
