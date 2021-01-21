# frozen_string_literal: true

RSpec.describe "routes for status", type: :routing do
  it { expect(get("/status")).to route_to("status#index") }
  it { expect(get("/ping")).to route_to("status#ping") }
end
