# frozen_string_literal: true

RSpec.describe LinkValidator do
  subject(:link_validator_response) { described_class.call(defendant_id: defendant_id) }

  let(:defendant_id) { "8cd0ba7e-df89-45a3-8c61-4008a2186d64" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let!(:prosecution_case) do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0],
    )
  end

  before do
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710")
  end

  it "returns true" do
    expect(link_validator_response).to eq true
  end

  context "when the hearing summary does not exist" do
    before do
      prosecution_case.body.delete("hearingSummary")
      prosecution_case.save!
    end

    it "returns false" do
      expect(link_validator_response).to eq false
    end
  end

  context "when the prosecution case defendant offence does not exist" do
    before do
      ProsecutionCaseDefendantOffence.destroy_all
    end

    it "returns false" do
      expect(link_validator_response).to eq false
    end
  end
end
