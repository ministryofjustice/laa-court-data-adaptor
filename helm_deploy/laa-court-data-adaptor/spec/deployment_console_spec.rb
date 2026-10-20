# frozen_string_literal: true

require_relative "./helm_helper"

RSpec.describe "Console deployment" do
  def deployment(values = {}, env: "uat")
    output, error, status = render(values, environment: env)
    expect(status.success?).to be(true), error

    output.find do |document|
      document["kind"] == "Deployment" && document.dig("metadata", "name") == "console-test-laa-court-data-adaptor-console"
    end
  end

  def console_container(values = {})
    deployment(values).dig("spec", "template", "spec", "containers").find { |container| container["name"] == "console" }
  end

  it "renders a console deployment with configured replicas and image" do
    resource = deployment
    container = console_container

    expect(resource.dig("spec", "replicas")).to eq(0)
    expect(container["image"]).to eq("754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-crime-apps-team/laa-court-data-adaptor:latest")
    expect(container["command"]).to eq(%w[sleep])
    expect(container["args"]).to eq(%w[infinity])
    expect(container["resources"]).to eq(
      "requests" => { "cpu" => "100m", "memory" => "512Mi" },
      "limits" => { "cpu" => "1", "memory" => "1Gi" },
    )
  end

  it "uses matching labels for the deployment selector and pod" do
    resource = deployment
    selector = resource.dig("spec", "selector", "matchLabels")
    labels = resource.dig("spec", "template", "metadata", "labels")

    expect(selector).to eq(
      "app.kubernetes.io/name" => "console-test-laa-court-data-adaptor-console",
      "app.kubernetes.io/instance" => "console-test",
    )
    expect(labels).to include(selector)
    expect(labels["app.kubernetes.io/component"]).to eq("console")
  end

  it "disables service account token mounting and uses the configured database secret" do
    pod_spec = deployment.dig("spec", "template", "spec")
    env = console_container.to_h.fetch("env")
                           .map { |variable| [variable.fetch("name"), variable] }
                           .to_h

    expect(pod_spec["automountServiceAccountToken"]).to be(false)
    expect(env.dig("DATABASE_URL", "valueFrom", "secretKeyRef")).to eq("name" => "rds-instance-read-replica-output", "key" => "url")
    expect(env.dig("REDIS_URL", "valueFrom", "secretKeyRef")).to eq("name" => "ec-cluster-output", "key" => "url")
    expect(env.dig("HOST_ENV", "value")).to eq("uat")
    expect(env.dig("AWS_REGION", "value")).to eq("eu-west-2")
  end

  it "uses an overridden database secret name" do
    env = console_container("console.databaseSecret.name" => "console-database").fetch("env")
                                                                                .map { |variable| [variable.fetch("name"), variable] }
                                                                                .to_h

    expect(env.dig("DATABASE_URL", "valueFrom", "secretKeyRef", "name")).to eq("console-database")
  end

  it "omits the deployment when the console is disabled" do
    expect(deployment({ "console.enabled" => false })).to be_nil
  end

  it "omits the deployment when the environment is test" do
    expect(deployment({}, env: "test")).to be_nil
  end

  it "omits the deployment when the environment is dev" do
    expect(deployment({}, env: "dev")).to be_nil
  end

  it "fails to render when the database secret name is empty" do
    _output, error, status = render({ "console.databaseSecret.name" => "" }, environment: "uat")

    expect(status.success?).to be(false)
    expect(error).to include("console database secret name is required")
  end
end
