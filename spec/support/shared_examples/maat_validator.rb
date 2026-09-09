RSpec.shared_examples "a contract that validates maat_reference" do
  context "when maat_reference is already linked" do
    let(:maat_reference) { 5_635_423 }

    before do
      stub_maat_validation("already_linked_maat_reference", status: 400)
    end

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error("5635423 is already linked to a case.") }
    it { is_expected.to have_contract_metadata({ code: :maat_reference_already_linked }) }
  end

  context "when the maat api validator is not available" do
    before { allow(MaatApi::MaatReferenceValidator).to receive(:call).and_return(nil) }

    it { is_expected.to be_a_success }
  end

  context "when maat_reference is invalid" do
    let(:maat_reference) { 9_999_999 }

    before do
      stub_maat_validation("invalid_maat_reference", status: 400)
    end

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error("MAAT/REP ID [#{maat_reference}] is invalid") }
    it { is_expected.to have_contract_metadata({ code: nil }) }
  end
end
