require "action_dispatch/http/mime_type"

# In order to support the JSONAPI standard for v1 endpoints we need
# to register this custom mime type
JSONAPI_MIME_TYPES = %w[
  application/vnd.api+json
  text/x-json
  application/json
].freeze

Mime::Type.register JSONAPI_MIME_TYPES.first, :json, JSONAPI_MIME_TYPES
