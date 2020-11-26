# frozen_string_literal: true

RSpec.describe Api::Internal::V1::ProsecutionCasesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/internal/v1/prosecution_cases").to route_to("api/internal/v1/prosecution_cases#index")
    end

    context "when no API version is specified" do
      it "routes to #index" do
        expect(get: "/api/internal/prosecution_cases").to route_to("api/internal/v1/prosecution_cases#index")
      end
    end
  end
end
