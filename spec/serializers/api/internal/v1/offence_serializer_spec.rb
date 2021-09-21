RSpec.describe Api::Internal::V1::OffenceSerializer do
  let(:offence_data) { JSON.parse(file_fixture("offence/all_fields.json").read) }
  let(:offence) { HmctsCommonPlatform::Offence.new(offence_data) }

  describe "serialized offence" do
    describe "attributes" do
      let(:attributes) { described_class.new(offence).serializable_hash[:data][:attributes] }

      it "code" do
        expect(attributes[:code]).to eql("LA12505")
      end

      it "order_index" do
        expect(attributes[:order_index]).to eql(1)
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

      it "mode_of_trial_reason" do
        expect(attributes[:mode_of_trial_reason]).to eq({ description: "Court directs trial by jury", code: "5" })
      end

      it "plea" do
        expect(attributes[:plea]).to eq({ plea_date: "2020-04-12", plea_value: "NOT_GUILTY" })
      end
    end
  end
end
