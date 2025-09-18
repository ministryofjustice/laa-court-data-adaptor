RSpec.describe "routing", type: :routing do
  it "routes to #show" do
    expect(get: "/oauth/token/info").to route_to("doorkeeper/token_info#show")
  end
end
