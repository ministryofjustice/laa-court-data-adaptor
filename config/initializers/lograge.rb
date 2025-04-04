HEADERS_TO_FILTER = %w[HTTP_AUTHORIZATION HTTP_OCP_APIM_SUBSCRIPTION_KEY].freeze

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    {}.tap do |envs|
      event.payload[:request].headers.to_h.each do |key, value|
        envs[key] = value if key.downcase.starts_with?("http") && HEADERS_TO_FILTER.exclude?(key)
      end
    end
  end
end
