# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::CourtApplicationRepresentationOrderCreator do
  subject(:create_rep_order) do
    described_class.call(
      maat_reference:,
      subject_id:,
      offences:,
      defence_organisation:,
    )
  end

  let(:maat_reference) { 12_345_678 }
  let(:subject_id) { "8cd0ba7e-df89-45a3-8c61-4008a2186d64" }
  let(:offence_one) do
    {
      offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710",
      status_code: "AB",
      status_date: "2020-10-12",
      effective_start_date: "2020-10-12",
      effective_end_date: "2020-11-12",
    }
  end
  let(:offences) { [offence_one] }
  let(:court_application_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:defence_organisation) do
    {
      snake_cased_level: {
        snake_cased_item: 1,
      },
      snake_cased_item: "random value",
    }
  end
  let(:transformed_defence_organisation) do
    {
      snakeCasedLevel: {
        snakeCasedItem: 1,
      },
      snakeCasedItem: "random value",
    }
  end

  before do
    CourtApplication.create!(
      id: court_application_id,
      body: JSON.parse(file_fixture("court_application_search_result.json").read),
    )
    CourtApplicationDefendantOffence.create!(court_application_id:,
                                             defendant_id: subject_id,
                                             offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710",
                                             application_type: "4567")
  end

  it "calls the CommonPlatform::Api::RecordProsecutionCaseRepresentationOrder service once" do
    expect(CommonPlatform::Api::RecordCourtApplicationRepresentationOrder).to receive(:call).once.with(hash_including(application_reference: maat_reference, defence_organisation: transformed_defence_organisation))
    create_rep_order
  end

  context "with multiple offences" do
    let(:offence_two) do
      {
        offence_id: "f916e952-1c35-44d6-ba15-a149f92cc38a",
        status_code: "AB",
        status_date: "2020-10-12",
        effective_start_date: "2020-10-12",
        effective_end_date: "2020-11-12",
      }
    end
    let(:offences) { [offence_one, offence_two] }

    before do
      CourtApplicationDefendantOffence.create!(court_application_id:,
                                               defendant_id: subject_id,
                                               offence_id: "f916e952-1c35-44d6-ba15-a149f92cc38a",
                                               application_type: "4567")
    end

    it "calls the CommonPlatform::Api::RecordProsecutionCaseRepresentationOrder service twice" do
      expect(CommonPlatform::Api::RecordCourtApplicationRepresentationOrder).to receive(:call).twice.with(hash_including(application_reference: maat_reference, defence_organisation: transformed_defence_organisation))
      create_rep_order
    end

    context "when one offence does not have a status date" do
      before { offence_two.delete(:status_date) }

      it "calls the CommonPlatform::Api::RecordProsecutionCaseRepresentationOrder service once" do
        expect(CommonPlatform::Api::RecordCourtApplicationRepresentationOrder).to receive(:call).once.with(hash_including(application_reference: maat_reference, defence_organisation: transformed_defence_organisation))
        create_rep_order
      end
    end
  end

  context "with indifferent access" do
    let(:offence_one) do
      {
        "offence_id" => "cacbd4d4-9102-4687-98b4-d529be3d5710",
        "status_code" => "AB",
        "status_date" => "2020-10-12",
        "effective_start_date" => "2020-10-12",
        "effective_end_date" => "2020-11-12",
      }
    end

    it "calls the CommonPlatform::Api::RecordProsecutionCaseRepresentationOrder service once" do
      expect(CommonPlatform::Api::RecordCourtApplicationRepresentationOrder).to receive(:call).once.with(hash_including(application_reference: maat_reference, defence_organisation: transformed_defence_organisation))
      create_rep_order
    end
  end

  context "with invalid defence_organisation data" do
    let(:defence_organisation) do
      {
        laa_contract_number: "CONTRACT REFERENCE",
        organisation: {
          name: "SOME ORGANISATION",
          address: {
            address1: "String",
            postcode: "Postcode Not Provided",
          },
          contact: {
            home: "Phone Not Provided",
            mobile: "Phone Not Provided",
            primary_email: "Email Not Provided",
            secondary_email: "Email Not Provided",
          },
        },
      }
    end
    let(:transformed_defence_organisation) do
      {
        laaContractNumber: "CONTRACT REFERENCE",
        organisation: {
          name: "SOME ORGANISATION",
          address: {
            address1: "String",
          },
          contact: {},
        },
      }
    end

    it "sanitises the data" do
      expect(CommonPlatform::Api::RecordCourtApplicationRepresentationOrder).to receive(:call).once.with(hash_including(application_reference: maat_reference, defence_organisation: transformed_defence_organisation))
      create_rep_order
    end
  end
end
