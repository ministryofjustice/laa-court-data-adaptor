# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  include AuthorisedRequestHelper

  controller do
    def index
      head :ok
    end
  end

  it_behaves_like "an unauthorised request"

  it "returns an X-Request-ID on every request" do
    get :index
    expect(response.headers).to include("X-Request-ID")
  end

  context "when the X-Request-ID is included by an external service" do
    before do
      request.headers["X-Request-ID"] = "XYZ"
    end

    it "returns an X-Request-ID on every request" do
      get :index
      expect(response.headers["X-Request-ID"]).to eq("XYZ")
    end
  end
end
