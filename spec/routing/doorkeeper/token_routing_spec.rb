RSpec.describe "routing", type: :routing do
  it "routes to #revoke" do
    expect(post: "/oauth/revoke").to route_to("doorkeeper/tokens#revoke")
  end

  it "routes to #introspect" do
    expect(post: "/oauth/introspect").to route_to("doorkeeper/tokens#introspect")
  end

  it "routes to #create" do
    expect(post: "/oauth/token").to route_to("doorkeeper/tokens#create")
  end
end
