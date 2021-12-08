# frozen_string_literal: true

RSpec.describe Api::External::V2::HearingResultsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/external/v2/hearing_results").to route_to("api/external/v2/hearing_results#create")
    end

    context "when no API version is specified" do
      it "routes to #create" do
        expect(post: "/api/external/hearings").to route_to("api/external/v1/hearing_results#create")
      end
    end
  end
end
