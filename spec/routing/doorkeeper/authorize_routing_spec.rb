RSpec.describe "routing", type: :routing do
  it "routes to #show" do
    expect(get: "/oauth/authorize/native").to route_to("doorkeeper/authorizations#show")
  end

  it "routes to #new" do
    expect(get: "/oauth/authorize").to route_to("doorkeeper/authorizations#new")
  end

  it "routes to #destroy" do
    expect(delete: "/oauth/authorize").to route_to("doorkeeper/authorizations#destroy")
  end

  it "routes to #create" do
    expect(post: "/oauth/authorize").to route_to("doorkeeper/authorizations#create")
  end
end
