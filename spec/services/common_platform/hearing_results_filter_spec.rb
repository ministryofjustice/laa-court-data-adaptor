RSpec.describe CommonPlatform::HearingResultsFilter do
  describe "#call" do
    subject(:filter_call) do
      described_class.new(body, defendant_id: defendant_id).call
    end

    let(:body) do
      {
        "hearing" => {
          "prosecutionCases" => [
            {
              "defendants" => [
                { "id" => 1, "name" => "Defendant 1" },
                { "id" => 2, "name" => "Defendant 2" },
              ],
            },
            {
              "defendants" => [
                { "id" => 3, "name" => "Defendant 3" },
              ],
            },
          ],
        },
      }
    end

    context "when defendant_id is nil" do
      let(:defendant_id) { nil }

      it { is_expected.to eq(body) }
    end

    context "when defendant_id is provided" do
      let(:defendant_id) { 2 }

      it "filters the defendants by defendant_id" do
        expect(filter_call).to eq(
          {
            "hearing" => {
              "prosecutionCases" => [
                {
                  "defendants" => [
                    { "id" => 2, "name" => "Defendant 2" },
                  ],
                },
                {
                  "defendants" => [],
                },
              ],
            },
          },
        )
      end
    end
  end
end
