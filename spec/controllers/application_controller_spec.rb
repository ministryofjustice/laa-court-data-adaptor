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

  context "when appending data to the logs" do
    before do
      request.remote_ip = "1.0.0.1"
      request.user_agent = "RSpec user agent"
    end

    it "logs a message with user agent and remote ip" do
      events = capture_semantic_logger_events do
        get :index
      end

      expect(events).to include(
        a_semantic_logger_event(payload_includes: { remote_ip: "1.0.0.1", user_agent: "RSpec user agent" }),
      )
    end
  end
end
