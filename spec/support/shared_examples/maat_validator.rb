RSpec.shared_examples "a contract that validates maat_reference" do
  let(:reference_validator_result) { instance_double(MaatApi::MaatReferenceValidator::Result, error_code:) }

  before do
    allow(MaatApi::MaatReferenceValidator).to receive(:call).with(maat_reference:).and_return(reference_validator_result)
  end

  context "when maat_reference is already linked" do
    let(:maat_reference) { 5_635_423 }
    let(:error_code) { :already_linked }

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error("is already linked to another case") }
    it { is_expected.to have_contract_metadata({ code: "already_linked" }) }
  end

  context "when maat_reference is invalid" do
    let(:maat_reference) { 9_999_999 }

    let(:error_code) { :invalid }

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error("is not a valid MAAT reference") }
    it { is_expected.to have_contract_metadata({ code: "invalid" }) }
  end

  context "when maat_reference has no common platform data" do
    let(:maat_reference) { 9_999_999 }

    let(:error_code) { :no_common_platform_data }

    it { is_expected.not_to be_a_success }
    it { is_expected.to have_contract_error("cannot be linked right now as we do not have all the required information, please try again later") }
    it { is_expected.to have_contract_metadata({ code: "no_common_platform_data" }) }
  end
end
