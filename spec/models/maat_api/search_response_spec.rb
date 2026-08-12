RSpec.describe MaatApi::SearchResponse, type: :model do
  describe "#initialize" do
    it "extracts status and body from Faraday response" do
      faraday_response = instance_double(Faraday::Response, status: 200, body: { id: "123" })
      response = described_class.new(faraday_response)

      expect(response.body).to eq({ id: "123" })
    end

    it "handles nil faraday response" do
      response = described_class.new(nil)

      expect(response.body).to be_nil
    end
  end

  describe "#success?" do
    it "returns true when Faraday success is true" do
      faraday_response = instance_double(Faraday::Response, success?: true, body: {})
      response = described_class.new(faraday_response)

      expect(response.success?).to be true
    end

    it "returns false when Faraday success is false" do
      faraday_response = instance_double(Faraday::Response, success?: false, body: {})
      response = described_class.new(faraday_response)

      expect(response.success?).to be false
    end
  end

  describe "#not_found?" do
    it "returns true for 404 status" do
      faraday_response = instance_double(Faraday::Response, status: 404, body: {})
      response = described_class.new(faraday_response)

      expect(response.not_found?).to be true
    end

    it "returns false for 200" do
      faraday_response = instance_double(Faraday::Response, status: 200, body: {})
      response = described_class.new(faraday_response)

      expect(response.not_found?).to be false
    end

    it "returns false for other 4xx status codes" do
      [400, 401, 403, 422].each do |status|
        faraday_response = instance_double(Faraday::Response, status: status, body: {})
        response = described_class.new(faraday_response)

        expect(response.not_found?).to be false
      end
    end

    it "returns false when status is nil" do
      faraday_response = instance_double(Faraday::Response, status: nil, body: {})
      response = described_class.new(faraday_response)

      expect(response.not_found?).to be false
    end
  end
end
