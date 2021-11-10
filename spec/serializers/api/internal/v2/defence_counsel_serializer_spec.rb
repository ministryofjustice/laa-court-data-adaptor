RSpec.describe Api::Internal::V2::DefenceCounselSerializer do
  let(:serialized_data) do
    defence_counsel_data = JSON.parse(file_fixture("defence_counsel/all_fields.json").read)
    defence_counsel = HmctsCommonPlatform::DefenceCounsel.new(defence_counsel_data)

    described_class.new(defence_counsel).serializable_hash[:data]
  end

  describe "serialized data" do
    describe "attributes" do
      let(:attributes) { serialized_data[:attributes] }

      it "title" do
        expect(attributes[:title]).to eql("Mr.")
      end

      it "first_name" do
        expect(attributes[:first_name]).to eql("Francis")
      end

      it "middle_name" do
        expect(attributes[:middle_name]).to eql("Scott")
      end

      it "last_name" do
        expect(attributes[:last_name]).to eql("Fitzgerald")
      end

      it "status" do
        expect(attributes[:status]).to eql("status")
      end

      it "attendance_days" do
        expect(attributes[:attendance_days]).to eql(%w[2018-10-25])
      end

      it "defendants" do
        expect(attributes[:defendants]).to eql(%w[baff62ee-ae6e-4f6a-92f8-063a1269453c])
      end
    end
  end
end
