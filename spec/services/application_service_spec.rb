# frozen_string_literal: true

RSpec.describe ApplicationService do
  subject { described_class.call('some', 'arguments') }

  let(:described_instance) { instance_double('ApplicationService') }

  before do
    allow(ApplicationService).to receive(:new).and_return(described_instance)
  end

  it 'should initialize and call the instance' do
    expect(ApplicationService).to receive(:new).with('some', 'arguments')
    expect(described_instance).to receive(:call)
    subject
  end
end
