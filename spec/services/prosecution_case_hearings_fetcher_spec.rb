# frozen_string_literal: true

RSpec.describe ProsecutionCaseHearingsFetcher do
  let(:prosecution_case_id) { '5edd67eb-9d8c-44f2-a57e-c8d026defaa4' }
  let(:body) { JSON.parse(file_fixture('prosecution_case_search_result.json').read)['cases'][0] }

  let!(:prosecution_case) do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: body
    )
  end

  let(:hearing_id) { 'b935a64a-6d03-4da4-bba6-4d32cc2e7fb4' }

  subject { described_class.call(prosecution_case_id: prosecution_case_id) }

  it 'triggers a call to Api::GetHearingResults' do
    expect(Api::GetHearingResults).to receive(:call).with(hearing_id: hearing_id)
    subject
  end
end
