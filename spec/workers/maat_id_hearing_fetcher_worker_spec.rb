# frozen_string_literal: true

require "rails_helper"

RSpec.describe MaatIdHearingFetcherWorker do
  subject(:perform) { described_class.new.perform(maat_id) }

  let(:maat_id) { "1234567" }
  let(:prosecution_case) { ProsecutionCase.create!(body: "foo") }
  let(:defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(
      prosecution_case:,
      defendant_id: SecureRandom.uuid,
      offence_id: SecureRandom.uuid,
    )
  end
  let(:laa_reference) do
    LaaReference.create!(
      maat_reference: maat_id,
      linked: true,
      defendant_id: defendant_offence.defendant_id,
      user_name: "test_user",
    )
  end

  before do
    allow(CommonPlatform::Api::ProsecutionCaseHearingsFetcher).to receive(:call)
  end

  context "when the MAAT ID is found and the fetch succeeds" do
    before { laa_reference }

    it "calls ProsecutionCaseHearingsFetcher with the prosecution case id" do
      perform
      expect(CommonPlatform::Api::ProsecutionCaseHearingsFetcher).to have_received(:call)
        .with(prosecution_case_id: prosecution_case.id)
    end
  end

  context "when the fetch raises an error" do
    before do
      laa_reference
      allow(CommonPlatform::Api::ProsecutionCaseHearingsFetcher).to receive(:call)
        .and_raise(StandardError, "something went wrong")
    end

    it "re-raises the error" do
      expect { perform }.to raise_error(StandardError, "something went wrong")
    end
  end

  context "when no linked LaaReference exists for the MAAT ID" do
    it "raises an error" do
      expect { perform }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
