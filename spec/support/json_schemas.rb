# frozen_string_literal: true

RSpec.configure do |config|
  def load_schema_v1(file_name)
    return unless File.file?("#{Rails.root}/swagger/v1/#{file_name}")

    schema = JSON.parse(File.open("#{Rails.root}/swagger/v1/#{file_name}").read)

    JSON::Validator.add_schema(JSON::Schema.new(schema, [file_name]))
  end

  def load_schema_v2(file_name)
    return unless File.file?("#{Rails.root}/swagger/v2/#{file_name}")

    schema = JSON.parse(File.open("#{Rails.root}/swagger/v2/#{file_name}").read)

    JSON::Validator.add_schema(JSON::Schema.new(schema, [file_name]))
  end

  config.before(:suite) do
    # This runs *once* before the test suite starts to ensure that we can resolve all of the Swagger definitions
    Dir.glob("**/*.json", base: "swagger/v1").each { |file_name| load_schema_v1(file_name) }
    Dir.glob("**/*.json", base: "swagger/v2").each { |file_name| load_schema_v2(file_name) }
  end
end
