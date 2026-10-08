# frozen_string_literal: true

require "open3"
require "yaml"

RSpec.describe "External ingress fingerprint" do
  let(:chart) { File.expand_path("../", __dir__) }
  let(:fingerprint) { "0123456789abcdef0123456789abcdef0123456789" }
  let(:snippet_key) { "nginx.ingress.kubernetes.io/server-snippet" }

  let(:expected_server_snippet) do
    <<~SNIPPET
      set $accept false;

      # Do a case-insensitive comparison of the ssl client fingerprint
      if ($ssl_client_fingerprint ~* "^#{fingerprint}$") {
        set $accept true;
      }
      if ($accept != true) {
        return 423;
      }
    SNIPPET
  end

  def render(values = {}, environment: "uat")
    overrides = values.flat_map do |key, value|
      flag = [true, false].include?(value) ? "--set" : "--set-string"
      [flag, "#{key}=#{value}"]
    end
    Open3.capture3(
      "helm", "template", "fingerprint-test", chart,
      "--values", File.join(chart, "public-values/#{environment}.yaml"),
      *overrides
    )
  end

  def ingress(values = {}, environment: "uat")
    output, error, status = render(values, environment:)
    expect(status.success?).to be(true), error
    YAML.load_stream(output).find do |document|
      document["kind"] == "Ingress" && document.dig("metadata", "name").end_with?("-external")
    end
  end

  it "renders the fingerprint restriction when requireCertFingerprint is true" do
    resource = ingress({ "certFingerprint" => fingerprint, "ingress.requireCertFingerprint" => true })

    expect(resource.dig("metadata", "annotations", snippet_key)).to eq(expected_server_snippet)
  end

  it "renders the fingerprint restriction when requireCertFingerprint is false" do
    resource = ingress({ "certFingerprint" => fingerprint, "ingress.requireCertFingerprint" => false })

    expect(resource.dig("metadata", "annotations", snippet_key)).to eq(expected_server_snippet)
  end

  it "fails closed with a missing required fingerprint" do
    _output, error, status = render({ "ingress.requireCertFingerprint" => true })

    expect(status.success?).to be(false)
    expect(error).to include("certFingerprint is required when ingress.requireCertFingerprint is true")
  end

  it "fails closed with an empty required fingerprint" do
    _output, error, status = render({ "ingress.requireCertFingerprint" => true, "certFingerprint" => "" })

    expect(status.success?).to be(false)
    expect(error).to include("certFingerprint is required when ingress.requireCertFingerprint is true")
  end

  it "omits the snippet when the fingerprint is optional and absent" do
    annotations = ingress({ "ingress.requireCertFingerprint" => false }).dig("metadata", "annotations")

    expect(annotations).not_to have_key(snippet_key)
    expect(annotations["nginx.ingress.kubernetes.io/auth-tls-verify-client"]).to eq("optional_no_ca")
  end

  it "omits the snippet when the optional fingerprint is explicitly empty" do
    annotations = ingress({ "certFingerprint" => "" }).dig("metadata", "annotations")

    expect(annotations).not_to have_key(snippet_key)
  end

  %w[dev uat test].each do |environment|
    it "preserves the existing #{environment} annotations without a fingerprint" do
      values = YAML.load_file(File.join(chart, "public-values/#{environment}.yaml"))
      annotations = ingress(environment:).dig("metadata", "annotations")

      expect(annotations).not_to have_key(snippet_key)
      expect(annotations).to include(values.fetch("ingress").fetch("externalAnnotations"))
    end
  end

  it "renders no external ingress when ingress is disabled" do
    expect(ingress({ "ingress.enabled" => false, "ingress.requireCertFingerprint" => true })).to be_nil
  end
end
