# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
filter_sensitive_info = lambda do |_key, value|
  next if value.frozen?

  next if /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/i.match?(value.to_s)

  value.to_s.replace "[FILTERED]"
end

Rails.application.config.filter_parameters += [
  :password,
  :passw,
  :secret,
  :token,
  :_key,
  :crypt,
  :salt,
  :certificate,
  :otp,
  :ssn,
  filter_sensitive_info,
]
