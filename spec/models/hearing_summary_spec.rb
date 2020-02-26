# frozen_string_literal: true

RSpec.describe HearingSummary, type: :model do
  let(:hearing_summary_hash) do
    {
      'hearingId' => 'UUID',
      'jurisdictionType' => 'Magistrate',
      'courtCenter' => {
        'id' => '1',
        'name' => 'Westminster',
        'welshName' => 'Westminster',
        'roomId' => '1',
        'roomName' => 'Court 1',
        'welshRoomName' => 'Court 1',
        'address' => {
          'address 1' => 'Westminster Magistrates Court',
          'address 2' => '181 Marylebone Road',
          'address 3' => 'Westminster',
          'address 4' => 'London',
          'address 5' => 'United Kingdom',
          'postcode' => 'NW1 5BR'
        }
      },
      'hearingType' => {
        'id' => '1',
        'description' => 'Committal for Sentencing',
        'code' => 'AA1'
      },
      'defendants' => ['UUID']
    }
  end

  subject(:hearing_summary) { described_class.new(body: hearing_summary_hash) }

  before { hearing_summary.hearing_date = '2020-02-01' }

  it { expect(hearing_summary.id).to eq('UUID') }
  it { expect(hearing_summary.jurisdiction_type).to eq('Magistrate') }
  it { expect(hearing_summary.court_centre_id).to eq('1') }
  it { expect(hearing_summary.court_centre_name).to eq('Westminster') }
  it { expect(hearing_summary.court_centre_welsh_name).to eq('Westminster') }
  it { expect(hearing_summary.court_centre_room_id).to eq('1') }
  it { expect(hearing_summary.court_centre_room_name).to eq('Court 1') }
  it { expect(hearing_summary.court_centre_welsh_room_name).to eq('Court 1') }
  it { expect(hearing_summary.court_centre_address_1).to eq('Westminster Magistrates Court') }
  it { expect(hearing_summary.court_centre_address_2).to eq('181 Marylebone Road') }
  it { expect(hearing_summary.court_centre_address_3).to eq('Westminster') }
  it { expect(hearing_summary.court_centre_address_4).to eq('London') }
  it { expect(hearing_summary.court_centre_address_5).to eq('United Kingdom') }
  it { expect(hearing_summary.court_centre_postcode).to eq('NW1 5BR') }
  it { expect(hearing_summary.hearing_type_id).to eq('1') }
  it { expect(hearing_summary.hearing_type_description).to eq('Committal for Sentencing') }
  it { expect(hearing_summary.hearing_type_code).to eq('AA1') }
  it { expect(hearing_summary.defendants).to eq(['UUID']) }
  it { expect(hearing_summary.hearing_date).to eq('2020-02-01') }
end
