require "pact"
require "pact/rspec"

RSpec.shared_context "with laa-maat-court-data-api consumer pact" do
  has_http_pact_between "laa-court-data-adaptor", "laa-maat-court-data-api", opts: { pact_dir: "spec/pacts" }
end
