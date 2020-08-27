# frozen_string_literal: true

RSpec.describe Defendant, type: :model do
  let(:prosecution_case_hash) do
    JSON.parse(file_fixture('prosecution_case_search_result.json').read)['cases'][0]
  end

  let(:defendant_hash) do
    prosecution_case_hash['defendantSummary'][0]
  end

  let(:prosecution_case_id) { nil }

  let(:details_hash) { nil }

  subject(:defendant) { described_class.new(body: defendant_hash, details: details_hash, prosecution_case_id: prosecution_case_id) }

  it { expect(defendant.name).to eq('George Walsh') }
  it { expect(defendant.first_name).to eq('George') }
  it { expect(defendant.last_name).to eq('Walsh') }
  it { expect(defendant.date_of_birth).to eq('1980-01-01') }
  it { expect(defendant.national_insurance_number).to eq('HB133542A') }
  it { expect(defendant.arrest_summons_number).to eq('ARREST123') }
  it { expect(defendant.prosecution_case).to be_nil }

  context 'prosecution case information' do
    before do
      ProsecutionCase.create!(id: prosecution_case_id, body: prosecution_case_hash)
    end

    let(:prosecution_case_id) { '5edd67eb-9d8c-44f2-a57e-c8d026defaa4' }

    it { expect(defendant.prosecution_case_id).to eq('5edd67eb-9d8c-44f2-a57e-c8d026defaa4') }
    it { expect(defendant.prosecution_case).to be_a(ProsecutionCase) }
    it { expect(defendant.prosecution_case).to be_persisted }
  end

  it 'initialises Offence without details' do
    expect(Offence).to receive(:new).with(body: defendant_hash['offenceSummary'][0], details: nil)
    defendant.offences
  end

  context 'post linking' do
    let(:offences) do
      [instance_double('Offence', maat_reference: nil)]
    end

    before do
      allow(defendant).to receive(:offences).and_return(offences)
    end

    it { expect(defendant.maat_reference).to be_nil }
    it { expect(defendant.representation_order_date).to be_nil }
    it { expect(defendant.defence_organisation).to be_nil }

    context 'when a maat_reference is linked' do
      let(:offences) do
        [instance_double('Offence', maat_reference: '123123')]
      end

      before do
        ProsecutionCase.create!(id: prosecution_case_hash['prosecutionCaseId'], body: '{}')
      end

      it { expect(defendant.maat_reference).to eq('123123') }
      it { expect(defendant.representation_order_date).to be_nil }
      it { expect(defendant.defence_organisation_id).to be_nil }

      context 'when a representation_order is recorded' do
        before do
          ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_hash['prosecutionCaseId'],
                                                  defendant_id: defendant_hash['defendantId'],
                                                  offence_id: SecureRandom.uuid,
                                                  status_date: '2019-12-12',
                                                  defence_organisation: defence_organisation)
        end

        let(:defence_organisation) do
          {
            'organisation' => {
              'name' => 'SOME ORGANISATION'
            },
            'laaContractNumber' => 'CONTRACT REFERENCE'
          }
        end

        it { expect(defendant.representation_order_date).to eq('2019-12-12') }
        it { expect(defendant.defence_organisation_id).to eq('CONTRACT REFERENCE') }
      end
    end

    context 'when there are multiple offences' do
      context 'with nil and not-nil maat references' do
        let(:offences) do
          [instance_double('Offence', maat_reference: '123123'),
           instance_double('Offence', maat_reference: nil)]
        end

        it { expect(defendant.maat_reference).to eq('123123') }
      end

      context 'with duplicate maat references' do
        let(:offences) do
          [instance_double('Offence', maat_reference: '123123'),
           instance_double('Offence', maat_reference: nil),
           instance_double('Offence', maat_reference: '123123')]
        end

        it { expect(defendant.maat_reference).to eq('123123') }
      end

      context 'with different maat references' do
        let(:offences) do
          [instance_double('Offence', maat_reference: '123123'),
           instance_double('Offence', maat_reference: nil),
           instance_double('Offence', maat_reference: '321321')]
        end

        it { expect { defendant.maat_reference }.to raise_error StandardError, 'Too many maat references' }
      end
    end

    context 'when an offence has an unlink maat reference' do
      let(:offences) do
        [instance_double('Offence', maat_reference: 'Z123123'),
         instance_double('Offence', maat_reference: nil)]
      end

      it { expect(defendant.maat_reference).to be_nil }
      it { expect(defendant.representation_order_date).to be_nil }
      it { expect(defendant.defence_organisation).to be_nil }
    end
  end

  context 'when details are available' do
    let(:details_hash) do
      {
        'offences' => [
          {
            'id' => '3f153786-f3cf-4311-bc0c-2d6f48af68a1',
            'offenceCode' => 'TR68107',
            'modeOfTrial' => 'Summary'
          }
        ]
      }
    end

    it 'initialises Offence with details' do
      expect(Offence).to receive(:new).with(body: defendant_hash['offenceSummary'][0], details: details_hash['offences'][0])
      defendant.offences
    end
  end
end
