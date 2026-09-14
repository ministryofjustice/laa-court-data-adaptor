RSpec.shared_examples "a contract that validates maat_reference" do
  context "when maat_reference is already linked" do
    let(:maat_reference) { 5_635_423 }

    before do
      stub_maat_validation("already_linked_maat_reference", status: 400)
    end

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error("is already linked to another case") }
    it { is_expected.to have_contract_metadata({ code: "already_linked" }) }
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
    it { is_expected.to have_contract_error("is not a valid MAAT reference") }
    it { is_expected.to have_contract_metadata({ code: "invalid" }) }
  end

  context "when maat_reference has no common platform data" do
    let(:maat_reference) { 9_999_999 }

    before do
      stub_maat_validation("no_common_platform_data", status: 400)
    end

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error("cannot be linked right now as we do not have all the required information, please try again later") }
    it { is_expected.to have_contract_metadata({ code: "no_common_platform_data" }) }
  end
end
