RSpec.describe Api::Internal::V1::OffenceSerializer do
  let(:serialized_data) do
    offence_data = JSON.parse(file_fixture("offence/all_fields.json").read)
    offence = Offence.new(body: offence_data, details: [offence_data])

    described_class.new(offence).serializable_hash[:data]
  end

  describe "offence serialized data" do
    describe "attributes" do
      let(:attributes) { serialized_data[:attributes] }

      it "code" do
        expect(attributes[:code]).to eql("LA12505")
      end

      it "order_index" do
        expect(attributes[:order_index]).to be(1)
      end

      it "title" do
        expect(attributes[:title]).to eql("Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable")
      end

      it "legislation" do
        expect(attributes[:legislation]).to eql("Common law")
      end

      it "mode_of_trial" do
        expect(attributes[:mode_of_trial]).to eq("Either way")
      end

      it "mode_of_trial_reasons" do
        expect(attributes[:mode_of_trial_reasons]).to eq([{ description: "Court directs trial by jury", code: "5" }])
      end

      it "pleas" do
        expect(attributes[:pleas]).to eq([{ pleaded_at: "2020-04-12", code: "NOT_GUILTY" }])
      end
    end

    describe "relationships" do
      let(:relationships) { serialized_data[:relationships] }

      it "judicial_results" do
        expected = [{
          id: "5cb61858-7095-42d6-8a52-966593f17db0",
          type: :judicial_result,
        }]

        expect(relationships[:judicial_results][:data]).to eq(expected)
      end
    end
  end
end
