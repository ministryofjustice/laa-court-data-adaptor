# frozen_string_literal: true

RSpec.describe Defendant, type: :model do
  let(:defendant_hash) do
    JSON.parse(file_fixture('prosecution_case_search_result.json').read)['cases'][0]['defendantSummary'][0]
  end

  subject(:defendant) { described_class.new(body: defendant_hash) }

  it { expect(defendant.name).to eq('George Walsh') }
  it { expect(defendant.date_of_birth).to eq('1980-01-01') }
  it { expect(defendant.national_insurance_number).to eq('HB133542A') }
  it { expect(defendant.arrest_summons_number).to eq('ARREST123') }

  describe '#maat_reference' do
    before do
      allow(defendant).to receive(:offences).and_return(offences)
    end

    context 'with no offences' do
      let(:offences) { [] }

      it { expect(defendant.maat_reference).to be_nil }
    end

    context 'when offence with no maat reference' do
      let(:offences) do
        [instance_double('Offence', maat_reference: nil)]
      end

      it { expect(defendant.maat_reference).to be_nil }
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
    end
  end
end
