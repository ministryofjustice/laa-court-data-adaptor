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

      it "judicial_results" do
        expected = [{
          cjs_code: "4600",
          is_adjournement_result: false,
          is_available_for_court_extract: true,
          is_convicted_result: false,
          is_financial_result: false,
          label: "Found guilty on all charges",
          ordered_date: "2021-03-10",
          qualifier: "Qualifier",
          result_text: "Result",
        }]

        expect(attributes[:judicial_results]).to eq(expected)
      end
    end
  end
end
