# frozen_string_literal: true

RSpec.describe ApplicationService do
  subject(:call_application_service) { described_class.call("some", "arguments") }

  let(:described_instance) { instance_double(described_class) }

  before do
    allow(described_class).to receive(:new).and_return(described_instance)
  end

  it "initialises and calls the instance" do
    expect(described_class).to receive(:new).with("some", "arguments")
    expect(described_instance).to receive(:call)
    call_application_service
  end
end
