# frozen_string_literal: true

RSpec.describe Api::External::V1::HearingResultsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/external/v1/hearings").to route_to("api/external/v1/hearing_results#create")
    end
  end
end
