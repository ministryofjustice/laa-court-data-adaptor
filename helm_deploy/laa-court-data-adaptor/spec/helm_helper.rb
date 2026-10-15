require "open3"
require "yaml"

def render(values = {}, environment: "test")
  chart = File.expand_path("../", __dir__)

  overrides = values.flat_map do |key, value|
    flag = [true, false].include?(value) ? "--set" : "--set-string"
    [flag, "#{key}=#{value}"]
  end

  output, error, status = Open3.capture3(
    "helm", "template", "console-test", chart,
    "--values", File.join(chart, "values/#{environment}.yaml"),
    *overrides
  )

  [YAML.load_stream(output), error, status]
end
