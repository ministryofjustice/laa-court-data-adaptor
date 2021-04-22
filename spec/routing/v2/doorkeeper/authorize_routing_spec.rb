# frozen_string_literal: true

RSpec.describe "routing", type: :routing do
  it "routes to #new" do
    expect(get: "/v2/oauth/authorize").to route_to("v2/doorkeeper/authorizations#new")
  end

  it "routes to #show" do
    expect(get: "/v2/oauth/authorize/native").to route_to("v2/doorkeeper/authorizations#show")
  end

  it "routes to #destroy" do
    expect(delete: "/v2/oauth/authorize").to route_to("v2/doorkeeper/authorizations#destroy")
  end

  it "routes to #create" do
    expect(post: "/v2/oauth/authorize").to route_to("v2/doorkeeper/authorizations#create")
  end

  context "when no API version is specified" do
    it "routes to #show" do
      expect(get: "/oauth/authorize/native").to route_to("v1/doorkeeper/authorizations#show")
    end

    it "routes to #new" do
      expect(get: "/oauth/authorize").to route_to("v1/doorkeeper/authorizations#new")
    end

    it "routes to #destroy" do
      expect(delete: "/oauth/authorize").to route_to("v1/doorkeeper/authorizations#destroy")
    end

    it "routes to #create" do
      expect(post: "/oauth/authorize").to route_to("v1/doorkeeper/authorizations#create")
    end
  end
end
