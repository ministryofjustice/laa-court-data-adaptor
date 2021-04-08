# frozen_string_literal: true

RSpec.describe DefenceOrganisation, type: :model do
  subject(:defence_organisation) { described_class.new(body: defence_organisation_data) }

  context "with required fields" do
    let(:defence_organisation_data) { JSON.parse(file_fixture("defence_organisation/required_fields.json").read) }

    it { expect(defence_organisation.id).to be_nil }
    it { expect(defence_organisation.name).to eq("The Johnson Partnership") }
    it { expect(defence_organisation.address1).to be_nil }
    it { expect(defence_organisation.address2).to be_nil }
    it { expect(defence_organisation.address3).to be_nil }
    it { expect(defence_organisation.address4).to be_nil }
    it { expect(defence_organisation.address5).to be_nil }
    it { expect(defence_organisation.postcode).to be_nil }
  end

  context "with all fields" do
    let(:defence_organisation_data) { JSON.parse(file_fixture("defence_organisation/all_fields.json").read) }

    it { expect(defence_organisation.id).to eq("11223344") }
    it { expect(defence_organisation.name).to eq("The Johnson Partnership") }
    it { expect(defence_organisation.address1).to eq("104") }
    it { expect(defence_organisation.address2).to eq("Fleet Street") }
    it { expect(defence_organisation.address3).to eq("Westminster") }
    it { expect(defence_organisation.address4).to eq("London") }
    it { expect(defence_organisation.address5).to eq("GB") }
    it { expect(defence_organisation.postcode).to eq("EC4A 2AH") }
  end
end
