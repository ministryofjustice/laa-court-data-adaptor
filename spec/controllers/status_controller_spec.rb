# frozen_string_literal: true

RSpec.describe StatusController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #ping" do
    context "when environment variables not set" do
      before { get :ping }

      it { expect(response).to have_http_status(:success) }

      it "returns \"Not Available\"" do
        expect(JSON.parse(response.body).values).to be_all("Not Available")
      end
    end

    context "when environment variables set" do
      let(:expected_json) do
        { app_branch: "feature_branch",
          build_date: "20150721",
          build_tag: "test",
          commit_id: "123456" }.to_json
      end

      before do
        default = "Not Available"
        allow(ENV).to receive(:fetch).with("APP_BRANCH", default).and_return("feature_branch")
        allow(ENV).to receive(:fetch).with("BUILD_DATE", default).and_return("20150721")
        allow(ENV).to receive(:fetch).with("BUILD_TAG", default).and_return("test")
        allow(ENV).to receive(:fetch).with("COMMIT_ID", default).and_return("123456")
        get :ping
      end

      it { expect(response).to have_http_status(:success) }

      it "returns JSON" do
        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it "returns JSON with app information" do
        expect(response.body).to eq(expected_json)
      end
    end
  end
end
