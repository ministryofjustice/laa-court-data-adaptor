RSpec.describe MaatApi::SearchResponse, type: :model do
  describe "#initialize" do
    it "extracts status and body from Faraday response" do
      http_response = instance_double(Faraday::Response, status: 200, body: { id: "123" })
      response = described_class.new(http_response)

      expect(response.body).to eq({ id: "123" })
    end

    it "handles nil Faraday response without raising error" do
      response = described_class.new(nil)

      expect { response.maat_id }.not_to raise_error
    end
  end

  describe "#success?" do
    it "returns true when Faraday success is true" do
      http_response = instance_double(Faraday::Response, success?: true, body: {})
      response = described_class.new(http_response)

      expect(response.success?).to be true
    end

    it "returns false when Faraday success is false" do
      http_response = instance_double(Faraday::Response, success?: false, body: {})
      response = described_class.new(http_response)

      expect(response.success?).to be false
    end
  end

  describe "#not_found?" do
    it "returns true for 404 status" do
      http_response = instance_double(Faraday::Response, status: 404, body: {})
      response = described_class.new(http_response)

      expect(response.not_found?).to be true
    end

    it "returns false for 200" do
      http_response = instance_double(Faraday::Response, status: 200, body: {})
      response = described_class.new(http_response)

      expect(response.not_found?).to be false
    end

    it "returns false for other 4xx status codes" do
      [400, 401, 403, 422].each do |status|
        http_response = instance_double(Faraday::Response, status: status, body: {})
        response = described_class.new(http_response)

        expect(response.not_found?).to be false
      end
    end

    it "returns false when status is nil" do
      http_response = instance_double(Faraday::Response, status: nil, body: {})
      response = described_class.new(http_response)

      expect(response.not_found?).to be false
    end
  end

  describe "#maat_id" do
    it "returns maatId from the first response item" do
      http_response = instance_double(Faraday::Response, status: 200, body: [{ "maatId" => "MAT001", "name" => "John Doe" }])
      response = described_class.new(http_response)

      expect(response.maat_id).to eq("MAT001")
    end

    it "returns nil when body is empty array" do
      http_response = instance_double(Faraday::Response, status: 200, body: [])
      response = described_class.new(http_response)

      expect(response.maat_id).to be_nil
    end

    it "returns nil when maatId is not present" do
      http_response = instance_double(Faraday::Response, status: 200, body: [{ "name" => "John Doe" }])
      response = described_class.new(http_response)

      expect(response.maat_id).to be_nil
    end

    it "returns nil when body is nil" do
      http_response = instance_double(Faraday::Response, status: 200, body: nil)
      response = described_class.new(http_response)

      expect(response.maat_id).to be_nil
    end

    it "returns nil when http_response is nil" do
      response = described_class.new(nil)

      expect(response.maat_id).to be_nil
    end

    it "handles multiple items and returns first maatId" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "maatId" => "MAT001", "name" => "John Doe" },
        { "maatId" => "MAT002", "name" => "Jane Doe" },
      ])
      response = described_class.new(http_response)

      expect(response.maat_id).to eq("MAT001")
    end
  end

  describe "#existing_link?" do
    it "returns false when is_linked is false, libra_id is nil, and case_urn is nil" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => false, "linkingDetail" => {} },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be false
    end

    it "returns false when response is empty" do
      http_response = instance_double(Faraday::Response, status: 200, body: [{}])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be false
    end

    it "returns true when is_linked is true" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => true, "linkingDetail" => {} },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be true
    end

    it "returns true when libra_id is present" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => false, "linkingDetail" => { "libraId" => "LIBRA123" } },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be true
    end

    it "returns true when case_urn is present" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => false, "linkingDetail" => { "caseUrn" => "URN123" } },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be true
    end

    it "returns true when both libra_id and case_urn are present" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => false, "linkingDetail" => { "libraId" => "LIBRA123", "caseUrn" => "URN123" } },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be true
    end

    it "returns false when libra_id is blank" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => false, "linkingDetail" => { "libraId" => "", "caseUrn" => nil } },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be false
    end

    it "returns false when case_urn is blank" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => false, "linkingDetail" => { "libraId" => nil, "caseUrn" => "" } },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be false
    end

    it "returns false when body is empty array" do
      http_response = instance_double(Faraday::Response, status: 200, body: [])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be false
    end

    it "returns false when body is nil" do
      http_response = instance_double(Faraday::Response, status: 200, body: nil)
      response = described_class.new(http_response)

      expect(response.existing_link?).to be false
    end

    it "returns false when http_response is nil" do
      response = described_class.new(nil)

      expect(response.existing_link?).to be false
    end

    it "returns false when is_linked is present but not strictly true" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => "yes", "linkingDetail" => {} },
      ])
      response = described_class.new(http_response)

      expect(response.existing_link?).to be false
    end
  end

  describe "#linked_to_common_platform?" do
    it "returns true when the libra id carries the CP prefix and a case urn is present" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => true, "linkingDetail" => { "libraId" => "CP0001", "caseUrn" => "01AB1234567" } },
      ])
      response = described_class.new(http_response)

      expect(response.linked_to_common_platform?).to be true
    end

    it "returns false when the libra id does not carry the CP prefix" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => true, "linkingDetail" => { "libraId" => "LIBRA123", "caseUrn" => "01AB1234567" } },
      ])
      response = described_class.new(http_response)

      expect(response.linked_to_common_platform?).to be false
    end

    it "returns false when the case urn is missing" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => true, "linkingDetail" => { "libraId" => "CP0001" } },
      ])
      response = described_class.new(http_response)

      expect(response.linked_to_common_platform?).to be false
    end

    it "returns false when there is no linking detail" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => true, "linkingDetail" => nil },
      ])
      response = described_class.new(http_response)

      expect(response.linked_to_common_platform?).to be false
    end

    it "returns false when http_response is nil" do
      response = described_class.new(nil)

      expect(response.linked_to_common_platform?).to be false
    end
  end

  describe "#linked_case_urn" do
    it "returns the case urn the MAAT application is linked to" do
      http_response = instance_double(Faraday::Response, status: 200, body: [
        { "isLinked" => true, "linkingDetail" => { "libraId" => "CP0001", "caseUrn" => "01AB1234567" } },
      ])
      response = described_class.new(http_response)

      expect(response.linked_case_urn).to eq("01AB1234567")
    end

    it "returns nil when there is no linking detail" do
      http_response = instance_double(Faraday::Response, status: 200, body: [{ "isLinked" => true }])
      response = described_class.new(http_response)

      expect(response.linked_case_urn).to be_nil
    end
  end
end
