RSpec.describe Api::Internal::V1::OffenceSerializer do
  let(:serialized_data) do
    offence_summary_data = JSON.parse(file_fixture("offence_summary/all_fields.json").read)
    offence_data = JSON.parse(file_fixture("offence/all_fields.json").read)
    offence = Offence.new(body: offence_summary_data, details: [offence_data])

    described_class.new(offence).serializable_hash[:data]
  end

  describe "offence serialized data" do
    describe "attributes" do
      let(:attributes) { serialized_data[:attributes] }

      it "code" do
        expect(attributes[:code]).to eql("TH68026C")
      end

      it "order_index" do
        expect(attributes[:order_index]).to be(1)
      end

      it "title" do
        expect(attributes[:title]).to eql("Conspire to commit a burglary dwelling with intent to steal")
      end

      it "legislation" do
        expect(attributes[:legislation]).to eql("Contrary to section 1(1) of the    Criminal Law Act 1977.")
      end

      it "mode_of_trial" do
        expect(attributes[:mode_of_trial]).to eq("Indictable")
      end

      it "mode_of_trial_reasons" do
        expect(attributes[:mode_of_trial_reasons]).to eq([{ description: "Court directs trial by jury", code: "5" }])
      end

      it "pleas" do
        expect(attributes[:pleas]).to eq([{ pleaded_at: "2020-04-12", code: "NOT_GUILTY" }])
      end

      it "verdict" do
        expect(attributes[:verdict]).to eq({ verdict_date: "2020-04-12", originating_hearing_id: "dda833bb-4956-4c9a-a553-59c6af5c15a6" })
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
