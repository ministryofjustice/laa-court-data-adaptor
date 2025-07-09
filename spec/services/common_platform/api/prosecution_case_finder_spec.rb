require "rails_helper"

RSpec.describe CommonPlatform::Api::ProsecutionCaseFinder do
  subject(:result) { described_class.call(urn, defendant_id) }

  let(:urn) { "abcde" }
  let(:matching_record) { ProsecutionCase.new(body: { prosecutionCaseReference: urn }) }
  let(:non_matching_record) { ProsecutionCase.new(body: { prosecutionCaseReference: "ABCDE" }) }

  before do
    allow(CommonPlatform::Api::SearchProsecutionCase).to receive(:call).with(
      prosecution_case_reference: urn,
    ).and_return(urn_search_results)
  end

  context "when no defendant_id is provided" do
    let(:defendant_id) { nil }

    context "when search by URN returns a matching result" do
      let(:urn_search_results) {  [matching_record] }

      it "returns that result" do
        expect(result).to eq matching_record
      end
    end

    context "when search by URN returns a non-matching result" do
      let(:urn_search_results) { [non_matching_record] }

      it "returns nothing" do
        expect(result).to be_nil
      end
    end

    context "when search by URN returns two results" do
      let(:urn_search_results) { [matching_record, non_matching_record] }

      it "returns the matching result" do
        expect(result).to eq matching_record
      end
    end

    context "when search by URN returns no results" do
      let(:urn_search_results) { [] }

      it "returns nothing" do
        expect(result).to be_nil
      end
    end
  end

  context "when defendant_id is provided" do
    let(:defendant_id) { SecureRandom.uuid }

    context "when search by URN returns a result" do
      let(:urn_search_results) { [matching_record] }

      it "returns that result" do
        expect(result).to eq matching_record
      end
    end

    context "when search by URN returns no results" do
      let(:urn_search_results) { [] }

      context "when there is no local record" do
        it "returns nothing" do
          expect(result).to be_nil
        end
      end

      context "when there is a local record" do
        before do
          matching_record.save!
          ProsecutionCaseDefendantOffence.create!(
            prosecution_case: matching_record,
            defendant_id:,
            offence_id: SecureRandom.uuid,
          )
        end

        context "when the local record matches defendant_id" do
          let(:matching_record) do
            ProsecutionCase.new(body: {
              prosecutionCaseReference: urn,
              defendantSummary: [{ defendantId: defendant_id, defendantFirstName: "Jane", defendantLastName: "Doe", defendantDOB: "1984-01-01" }],
            })
          end

          before do
            allow(CommonPlatform::Api::SearchProsecutionCase).to receive(:call).with(
              name: "Jane Doe",
              date_of_birth: "1984-01-01",
            ).and_return(defendant_search_results)
          end

          context "when search by defendant returns a matching result" do
            let(:defendant_search_results) { [matching_record] }

            it "returns that result" do
              expect(result).to eq matching_record
            end
          end

          context "when search by defendant returns a non-matching result" do
            let(:defendant_search_results) { [non_matching_record] }

            it "returns nothing" do
              expect(result).to be_nil
            end
          end

          context "when search by defendant returns two results" do
            let(:defendant_search_results) { [matching_record, non_matching_record] }

            it "returns the matching result" do
              expect(result).to eq matching_record
            end
          end

          context "when search by defendant returns no results" do
            let(:defendant_search_results) { [] }

            it "returns nothing" do
              expect(result).to be_nil
            end
          end
        end

        context "when the local record does not match defendant id" do
          let(:matching_record) do
            ProsecutionCase.new(body: {
              prosecutionCaseReference: urn,
              defendantSummary: [{ defendantId: SecureRandom.uuid }],
            })
          end

          it "returns nothing" do
            expect(result).to be_nil
          end
        end
      end
    end
  end
end
