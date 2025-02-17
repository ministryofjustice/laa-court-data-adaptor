RSpec.describe CommonPlatform::Api::SchemaValidator do
  subject(:validate) { described_class.call(schema:, json_response:) }

  let(:schema) do
    JSON.parse(
      File.read("lib/schemas/api/progression.query.laa.application-laa.json"),
    )
  end

  let(:json_response) { JSON.parse(file_fixture("court_application_details/all_fields.json").read) }

  it "validates the response against the schema" do
    expect(validate).to be_truthy
  end

  it "returns false if the response is invalid" do
    json_response["applicationReference"] = nil

    expect(validate).to be_falsey
  end
end
