# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingEvent, type: :model do
  let(:hearing_event_hash) do
    JSON.parse(file_fixture('valid_hearing_logs.json').read)['events'][0]
  end

  subject(:defendant) { described_class.new(body: hearing_event_hash) }

  it { expect(defendant.description).to eq('Hearing started') }
  it { expect(defendant.occurred_at).to eq('2020-04-30T16:17:58.610Z') }
end
