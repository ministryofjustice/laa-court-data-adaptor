# frozen_string_literal: true

RSpec.describe Api::Internal::V1::DefendantSerializer do
  let(:defendant) do
    defendant_summary_data = JSON.parse(file_fixture("defendant_summary/all_fields.json").read)
    defendant_data = JSON.parse(file_fixture("defendant/all_fields.json").read)
    Defendant.new(body: defendant_summary_data, details: [defendant_data], prosecution_case_id: "123")
  end

  let(:serialized_data) do
    described_class.new(defendant).serializable_hash[:data]
  end

  describe "serialized data" do
    describe "attributes" do
      let(:attributes) { serialized_data[:attributes] }

      it "name" do
        expect(attributes[:name]).to eq("Bob Steven Smith")
      end

      it "date_of_birth" do
        expect(attributes[:date_of_birth]).to eq("1986-11-10")
      end

      it "national_insurance_number" do
        expect(attributes[:national_insurance_number]).to eq("AA123456C")
      end

      it "arrest_summons_number" do
        expect(attributes[:arrest_summons_number]).to eq("2100000000000267128K")
      end

      it "maat_reference" do
        expect(attributes[:maat_reference]).to eq("7555111")
      end

      it "prosecution_case_id" do
        expect(attributes[:prosecution_case_id]).to eq("123")
      end

      it "post_hearing_custody_statuses" do
        expect(attributes[:post_hearing_custody_statuses]).to eq(%w[A A])
      end
    end

    describe "relationships" do
      let(:relationships) { serialized_data[:relationships] }

      it "offences" do
        expected = [
          {
            id: "9aca847f-da4e-444b-8f5a-2ce7d776ab75",
            type: :offences,
          },
          {
            id: "4a852bd1-0068-422c-994f-78a5373ecd75",
            type: :offences,
          },
        ]

        expect(relationships[:offences][:data]).to eq(expected)
      end

      it "defence_organisation" do
        allow(defendant).to receive(:defence_organisation).and_return(DefenceOrganisation.new(body: { "laaContractNumber" => "88888" }))
        expect(relationships[:defence_organisation][:data]).to eq({ id: "88888", type: :defence_organisations })
      end

      it "prosecution_case" do
        allow(defendant).to receive(:prosecution_case).and_return(ProsecutionCase.new(id: "123"))
        expect(relationships[:prosecution_case][:data]).to eq({ id: "123", type: :prosecution_case })
      end

      it "judicial_results" do
        expect(relationships[:judicial_results][:data]).to eq([{ id: "be225605-fc15-47aa-b74c-efb8629db58e", type: :judicial_results }])
      end
    end
  end
end
