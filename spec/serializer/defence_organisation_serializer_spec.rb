# frozen_string_literal: true

RSpec.describe DefenceOrganisationSerializer do
  subject { described_class.new(defence_organisation).serializable_hash }

  let(:defence_organisation) do
    instance_double("DefenceOrganisation",
                    id: "UUID",
                    name: "The Johnson Partnership",
                    address1: "104",
                    address2: "Fleet Street",
                    address3: "Westminster",
                    address4: "London",
                    address5: "GB",
                    postcode: "EC4A 2AH")
  end

  context "with attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:name]).to eq("The Johnson Partnership") }
    it { expect(attribute_hash[:address1]).to eq("104") }
    it { expect(attribute_hash[:address2]).to eq("Fleet Street") }
    it { expect(attribute_hash[:address3]).to eq("Westminster") }
    it { expect(attribute_hash[:address4]).to eq("London") }
    it { expect(attribute_hash[:address5]).to eq("GB") }
    it { expect(attribute_hash[:postcode]).to eq("EC4A 2AH") }
  end
end
