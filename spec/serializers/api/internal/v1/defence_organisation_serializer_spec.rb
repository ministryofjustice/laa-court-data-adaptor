# frozen_string_literal: true

RSpec.describe Api::Internal::V1::DefenceOrganisationSerializer do
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

  let(:attributes) { subject[:data][:attributes] }

  it { expect(attributes[:name]).to eq("The Johnson Partnership") }
  it { expect(attributes[:address1]).to eq("104") }
  it { expect(attributes[:address2]).to eq("Fleet Street") }
  it { expect(attributes[:address3]).to eq("Westminster") }
  it { expect(attributes[:address4]).to eq("London") }
  it { expect(attributes[:address5]).to eq("GB") }
  it { expect(attributes[:postcode]).to eq("EC4A 2AH") }
end
