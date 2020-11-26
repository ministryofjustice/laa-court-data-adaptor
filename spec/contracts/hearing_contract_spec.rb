# frozen_string_literal: true

RSpec.describe HearingContract do
  subject { described_class.new.call(hash_for_validation) }

  let(:hash_for_validation) do
    {
      hearing: {
        id: hearing_id,
        jurisdictionType: jurisdiction_type,
        courtCentre: court_centre,
        type: type,
        hearingDays: [hearing_days],
      },
      sharedTime: shared_time,
    }
  end
  let(:hearing_id) { "224b9e22-8957-11ea-bc55-0242ac130003" }
  let(:jurisdiction_type) { "MAGISTRATES" }
  let(:court_centre) { { id: "28746ab8-8957-11ea-bc55-0242ac130003" } }
  let(:type) do
    {
      id: type_id,
      code: type_code,
      description: type_description,
    }
  end
  let(:type_id) { "2eb85d9e-8957-11ea-bc55-0242ac130003" }
  let(:type_code) { "PLE" }
  let(:type_description) { "Plea" }
  let(:hearing_days) do
    {
      sittingDay: sitting_day,
      listingSequence: listing_sequence,
      listedDurationMinutes: listed_duration_minutes,
    }
  end
  let(:sitting_day) { "2018-10-24 10:00:00" }
  let(:listing_sequence) { 1 }
  let(:listed_duration_minutes) { 120 }
  let(:shared_time) { "2018-10-25 11:30:00" }

  it { is_expected.to be_a_success }

  context "without a hearing id" do
    let(:hash_for_validation) do
      {
        hearing: {
          jurisdictionType: jurisdiction_type,
          courtCentre: court_centre,
          type: type,
          hearingDays: [hearing_days],
        },
        sharedTime: shared_time,
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "with an invalid hearing id" do
    let(:hearing_id) { "TEST" }

    it { is_expected.not_to be_a_success }
  end

  context "without a jurisdictionType" do
    let(:hash_for_validation) do
      {
        hearing: {
          id: hearing_id,
          courtCentre: court_centre,
          type: type,
          hearingDays: [hearing_days],
        },
        sharedTime: shared_time,
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "with an invalid jurisdictionType" do
    let(:jurisdiction_type) { "TEST" }

    it { is_expected.not_to be_a_success }
  end

  context "without a courtCentre" do
    let(:hash_for_validation) do
      {
        hearing: {
          id: hearing_id,
          jurisdictionType: jurisdiction_type,
          type: type,
          hearingDays: [hearing_days],
        },
        sharedTime: shared_time,
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "with an invalid courtCentre id" do
    let(:court_centre) { { id: "TEST" } }

    it { is_expected.not_to be_a_success }
  end

  context "without a type" do
    let(:hash_for_validation) do
      {
        hearing: {
          id: hearing_id,
          jurisdictionType: jurisdiction_type,
          courtCentre: court_centre,
          hearingDays: [hearing_days],
        },
        sharedTime: shared_time,
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "without a type id" do
    let(:type) do
      {
        code: type_code,
        description: type_description,
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "with an invalid type id" do
    let(:type_id) { "TEST" }

    it { is_expected.not_to be_a_success }
  end

  context "without a type code" do
    let(:type) do
      {
        id: type_id,
        description: type_description,
      }
    end

    it { is_expected.to be_a_success }
  end

  context "with an invalid type code" do
    let(:type_code) { "TEST" }

    it { is_expected.not_to be_a_success }
  end

  context "without a type description" do
    let(:type) do
      {
        id: type_id,
        code: type_code,
      }
    end

    it { is_expected.to be_a_success }
  end

  context "without hearingDays" do
    let(:hash_for_validation) do
      {
        hearing: {
          id: hearing_id,
          jurisdictionType: jurisdiction_type,
          courtCentre: court_centre,
          type: type,
        },
        sharedTime: shared_time,
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "without hearingDays sittingDay" do
    let(:hearing_days) do
      {
        listingSequence: listing_sequence,
        listedDurationMinutes: listed_duration_minutes,
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "with an invalid hearingDays sittingDay" do
    let(:sitting_day) { "TEST" }

    it { is_expected.not_to be_a_success }
  end

  context "without a hearingDays listingSequence" do
    let(:hearing_days) do
      {
        sittingDay: sitting_day,
        listedDurationMinutes: listed_duration_minutes,
      }
    end
    it { is_expected.to be_a_success }
  end

  context "with an invalid hearingDays listingSequence" do
    let(:listing_sequence) { "TEST" }

    it { is_expected.not_to be_a_success }
  end

  context "without a hearingDays listedDurationMinutes" do
    let(:hearing_days) do
      {
        sittingDay: sitting_day,
        listingSequence: listing_sequence,
      }
    end
    it { is_expected.not_to be_a_success }
  end

  context "with an invalid hearingDays listedDurationMinutes" do
    let(:listed_duration_minutes) { "TEST" }

    it { is_expected.not_to be_a_success }
  end

  context "without a sharedTime" do
    let(:hash_for_validation) do
      {
        hearing: {
          id: hearing_id,
          jurisdictionType: jurisdiction_type,
          courtCentre: court_centre,
          type: type,
          hearingDays: [hearing_days],
        },
      }
    end

    it { is_expected.not_to be_a_success }
  end

  context "with an invalid sharedTime" do
    let(:shared_time) { "TEST" }

    it { is_expected.not_to be_a_success }
  end
end
