# frozen_string_literal: true

RSpec.describe ProsecutionCase, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'Common Platform search' do
    let(:prosecution_case_result) do
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        ProsecutionCaseSearcher.call(prosecution_case_reference: '19GD1001816')
      end
    end

    let(:prosecution_case) { described_class.create(id: prosecution_case_id, body: prosecution_case_result.body['cases'][0]) }

    let(:prosecution_case_id) { '31cbe62d-b1ec-4e82-89f7-99dced834900' }

    it { expect(prosecution_case.prosecution_case_reference).to eq('19GD1001816') }
    it { expect(prosecution_case.defendants).to all be_a(Defendant) }
    it { expect(prosecution_case.hearing_summaries).to all be_a(HearingSummary) }

    it 'initialises Defendants without details' do
      expect(Defendant).to receive(:new).with(body: an_instance_of(Hash), details: nil, prosecution_case_id: prosecution_case_id).twice.and_call_original
      prosecution_case.defendants
    end

    context 'requesting hearing resulted' do
      let(:hearing_ids) { %w[311bb2df-4df5-4abe-bae3-82f144e1e5c5 c6cf04b5-901d-4a89-a9ab-767eb57306e4] }

      before do
        allow(prosecution_case).to receive(:hearing_summary_ids).and_return(hearing_ids)
        allow(Api::GetHearingResults).to receive(:call).with(hearing_id: hearing_ids[0]).and_return(hearing_one)
        allow(Api::GetHearingResults).to receive(:call).with(hearing_id: hearing_ids[1]).and_return(hearing_two)
      end

      let(:hearing_one) do
        Hearing.create(
          id: hearing_ids[0],
          body: {
            'id' => hearing_ids[0],
            'prosecutionCases' => [{
              'id' => '31cbe62d-b1ec-4e82-89f7-99dced834900',
              'defendants' => [{
                'id' => 'c6cf04b5-901d-4a89-a9ab-767eb57306e4'
              }]
            }]
          }
        )
      end

      let(:hearing_two) do
        Hearing.create(
          id: hearing_ids[1],
          body: {
            'id' => hearing_ids[1],
            'prosecutionCases' => [{
              'id' => '31cbe62d-b1ec-4e82-89f7-99dced834900',
              'defendants' => [{
                'id' => 'b70a36e5-13d3-4bb3-bb24-94db79b7708b'
              }]
            }]
          }
        )
      end

      it { expect(prosecution_case.hearings).to all be_a(Hearing) }
      it { expect(prosecution_case.hearing_ids).to eq(hearing_ids) }

      context 'when a hearing has not resulted' do
        let(:hearing_one) { nil }
        let(:hearing_two) { nil }

        it { expect(prosecution_case.hearings).to be_empty }
      end

      context 'when hearings are loaded' do
        before { prosecution_case.hearings }

        it 'initialises Defendants with detailed fetched from hearing' do
          expect(Defendant).to receive(:new).with(body: an_instance_of(Hash), details: an_instance_of(Hash), prosecution_case_id: prosecution_case_id).twice
          prosecution_case.defendants
        end

        context 'with no prosecution_case reference' do
          let(:hearing_one) { Hearing.create(id: hearing_ids[0], body: { 'id' => hearing_ids[0] }) }
          let(:hearing_two) { Hearing.create(id: hearing_ids[1], body: { 'id' => hearing_ids[1] }) }

          it 'initialises Defendants without details' do
            expect(Defendant).to receive(:new).with(body: an_instance_of(Hash), details: nil, prosecution_case_id: prosecution_case_id).twice
            prosecution_case.defendants
          end
        end
      end
    end
  end
end
