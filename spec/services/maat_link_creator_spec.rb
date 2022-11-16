# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe MaatLinkCreator do
  subject(:create_maat_link) { described_class.call(defendant_id, user_name, maat_reference) }

  include ActiveSupport::Testing::TimeHelpers

  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:user_name) { "bob-smith" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:offence_id) { "cacbd4d4-9102-4687-98b4-d529be3d5710" }
  let(:laa_reference) { LaaReference.create!(defendant_id: defendant_id, user_name: "caseWorker", maat_reference: maat_reference) }
  let(:response) { OpenStruct.new("status" => 200, "success?" => true) }

  before do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0],
    )

    ProsecutionCaseDefendantOffence.create!(
      prosecution_case_id: prosecution_case_id,
      defendant_id: defendant_id,
      offence_id: offence_id,
    )

    allow(Sqs::MessagePublisher).to receive(:call)
    allow(CommonPlatform::Api::RecordLaaReference).to receive(:call)
  end

  it "enqueues a PastHearingsFetcherWorker" do
    allow(CommonPlatform::Api::RecordLaaReference)
      .to receive(:call)
      .and_return(response)

    Sidekiq::Testing.fake! do
      freeze_time do
        Current.set(request_id: "XYZ") do
          expect(PastHearingsFetcherWorker)
            .to receive(:perform_at)
            .with(30.seconds.from_now, "XYZ", prosecution_case_id)
            .and_call_original

          create_maat_link
        end
      end
    end
  end

  it "calls the CommonPlatform::Api::RecordLaaReference service once" do
    expect(CommonPlatform::Api::RecordLaaReference)
      .to receive(:call)
      .once.with(hash_including(application_reference: "12345678"))
      .and_return(response)

    create_maat_link
  end

  it "calls the Sqs::MessagePublisher service once" do
    allow(CommonPlatform::Api::RecordLaaReference)
      .to receive(:call)
      .once.with(hash_including(application_reference: "12345678"))
      .and_return(response)

    expect(Sqs::MessagePublisher).to receive(:call).once

    create_maat_link
  end

  context "with multiple offences" do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it "calls the Sqs::MessagePublisher service once" do
      allow(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(Sqs::MessagePublisher).to receive(:call).once

      create_maat_link
    end

    it "calls the CommonPlatform::Api::RecordLaaReference service multiple times" do
      expect(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .twice.with(hash_including(application_reference: "12345678"))
        .and_return(response)

      create_maat_link
    end
  end

  context "when an LaaReference exists" do
    let!(:existing_laa_reference) { LaaReference.create!(defendant_id: SecureRandom.uuid, user_name: "MrDoe", maat_reference: maat_reference) }

    context "and it is no longer linked" do
      before do
        existing_laa_reference.update!(linked: false)

        allow(CommonPlatform::Api::RecordLaaReference)
          .to receive(:call)
          .and_return(response)
      end

      it "creates an LaaReference" do
        expect {
          create_maat_link
        }.to change(LaaReference, :count).by(1)
      end
    end
  end

  context "with a dummy_maat_reference" do
    let(:maat_reference) { "A10000000" }

    it "does not call the Sqs::MessagePublisher service" do
      allow(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(Sqs::MessagePublisher).not_to receive(:call)

      create_maat_link
    end

    it "creates a dummy maat_reference" do
      allow(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .with(hash_including(application_reference: "A10000000"))

      create_maat_link
    end
  end

  context "with no maat reference" do
    let(:maat_reference) { nil }

    it "creates a dummy_maat_reference" do
      allow(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(
        described_class.new(defendant_id, user_name, maat_reference).laa_reference,
      ).to be_dummy_maat_reference
    end
  end

  describe "linking twice" do
    it "marks previous record as unlinked and creates a new one marked as linked" do
      allow(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .and_return(response)

      expect {
        described_class.call(defendant_id, user_name, maat_reference)
        described_class.call(defendant_id, user_name, maat_reference)
      }.to change(LaaReference, :count).by(2)

      expect(LaaReference.where(linked: true).count).to be(1)
    end
  end

  context "when a POST request to Common Platform fails" do
    let(:response) { OpenStruct.new("status" => 500, "success?" => false) }

    before do
      allow(CommonPlatform::Api::RecordLaaReference)
        .to receive(:call)
        .and_return(response)
    end

    it "raises an error" do
      expect { create_maat_link }.to raise_error "Error posting LAA Reference to Common Platform"
    end

    it "reports to Sentry" do
      expect(Sentry).to receive(:capture_exception).with(
        any_instance_of(StandardError),
        {
          tags: {
            defendant_id: "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3",
            maat_reference: "12345678",
            offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710",
            request_id: nil,
            user_name: "bob-smith",
          },
        },
      )
      create_maat_link
      # rubocop disable Lint/SuppressedException
    rescue StandardError
      # rubocop enable Lint/SuppressedException
    end

    it "does not publish to the link created queue" do
      expect(Sqs::MessagePublisher).not_to receive(:call)
      create_maat_link
      # rubocop disable Lint/SuppressedException
    rescue StandardError
      # rubocop enable Lint/SuppressedException
    end
  end
end
