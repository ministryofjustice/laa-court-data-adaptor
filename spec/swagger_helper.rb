# frozen_string_literal: true

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Court Data Adaptor",
        description: "CDA exposes API endpoints to the LAA's View Court Data and
                      MAAT/MLRA applications and the HMCTS Common Platform in order to
                      exchange criminal court data between the two organisations.",
        version: "v1",
      },
      paths: {},
      components: {
        securitySchemes: {
          oAuth: {
            in: :header,
            type: :oauth2,
            description: "OAuth2 client credentials flow",
            flows: {
              clientCredentials: {
                scopes: [],
                tokenUrl: "/oauth/token",
              },
            },
          },
        },
        parameters: {
          transaction_id_header: {
            type: :uuid,
            name: "X-Request-ID",
            in: :header,
            required: false,
            description: "A unique identifier for an individual request that can be traced across multiple systems",
            example: "d7f509e8-309c-4262-a41d-ebbb44deab9e",
          },
        },
      },
    },
    "v2/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Court Data Adaptor",
        description: "CDA exposes API endpoints to the LAA's View Court Data and
                      MAAT/MLRA applications and the HMCTS Common Platform in order to
                      exchange criminal court data between the two organisations.",
        version: "v2",
      },
      paths: {},
      components: {
        securitySchemes: {
          oAuth: {
            in: :header,
            type: :oauth2,
            description: "OAuth2 client credentials flow",
            flows: {
              clientCredentials: {
                scopes: [],
                tokenUrl: "/oauth/token",
              },
            },
          },
        },
        parameters: {
          transaction_id_header: {
            type: :uuid,
            name: "X-Request-ID",
            in: :header,
            required: false,
            description: "A unique identifier for an individual request that can be traced across multiple systems",
            example: "d7f509e8-309c-4262-a41d-ebbb44deab9e",
          },
        },
      },
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
