# frozen_string_literal: true

RSpec.describe Provider, type: :model do
  let(:provider_hash) do
    JSON.parse(file_fixture('provider.json').read)
  end

  subject(:provider) { described_class.new(body: provider_hash) }

  it { expect(provider.defence_advocate_name).to eq('Neil Griffiths') }
  it { expect(provider.defence_advocate_status).to eq('Junior counsel') }
end
