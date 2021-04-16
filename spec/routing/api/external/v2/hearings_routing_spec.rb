# frozen_string_literal: true

RSpec.describe Api::External::V2::HearingsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/external/v2/hearings").to route_to("api/external/v2/hearings#create")
    end

    context "when no API version is specified" do
      it "routes to #create" do
        expect(post: "/api/external/hearings").to route_to("api/external/v1/hearings#create")
      end
    end
  end
end
