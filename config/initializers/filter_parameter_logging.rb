# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
filter_sensitive_info = ->(_key, value) do
  next if /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/i.match?(value.to_s)

  value.to_s.replace '[FILTERED]'
end

Rails.application.config.filter_parameters += [:password, filter_sensitive_info]
