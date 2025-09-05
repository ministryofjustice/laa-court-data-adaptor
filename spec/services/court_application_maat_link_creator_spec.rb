require "sidekiq/testing"

RSpec.describe CourtApplicationMaatLinkCreator do
  subject(:call_link_creator) { described_class.call(subject_id, user_name, maat_reference) }

  include ActiveSupport::Testing::TimeHelpers

  let(:maat_reference) { 12_345_678 }
  let(:subject_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:user_name) { "bob-smith" }
  let(:court_application_id) { "00004c9f-af9f-401a-b88b-78a4f0e08163" }
  let(:offence_id) { "f369a0f5-6faf-43f1-8725-fb79847107cc" }
  let(:laa_reference) { LaaReference.create!(defendant_id:, user_name: "caseWorker", maat_reference:) }
  let(:response) { OpenStruct.new("status" => 200, "success?" => true) }
  let(:court_application) do
    CourtApplication.create!(
      id: court_application_id,
      subject_id: subject_id,
      body: JSON.parse(file_fixture("court_application_summary.json").read),
    )
  end

  before do
    court_application

    allow(Sqs::MessagePublisher).to receive(:call)
    allow(CommonPlatform::Api::RecordCourtApplicationLaaReference).to receive(:call)
  end

  it "enqueues a HearingResultFetcherWorker per hearing day" do
    allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
      .to receive(:call)
      .and_return(response)

    Sidekiq::Testing.fake! do
      freeze_time do
        Current.set(request_id: "XYZ") do
          expect(HearingResultFetcherWorker)
            .to receive(:perform_at)
            .twice

          call_link_creator
        end
      end
    end
  end

  it "calls the CommonPlatform::Api::RecordCourtApplicationLaaReference service once" do
    allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
      .to receive(:call)
      .once.with(hash_including(application_reference: "12345678"))
      .and_return(response)

    expect(CommonPlatform::Api::RecordCourtApplicationLaaReference)
      .to receive(:call)
      .once
      .with(hash_including(application_reference: "12345678"))

    call_link_creator
  end

  it "calls the Sqs::MessagePublisher service once" do
    allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
      .to receive(:call)
      .once.with(hash_including(application_reference: "12345678"))
      .and_return(response)

    expect(Sqs::MessagePublisher).to receive(:call).once do |arg|
      expect(arg[:message]).to include(
        asn: "VE94015",
        cjsAreaCode: "1",
        cjsLocation: "B01LY",
        createdUser: "bob-smith",
      )

      expect(arg[:log_info]).to include(
        maat_reference: "12345678",
      )
    end

    call_link_creator
  end

  context "with multiple offences" do
    before do
      first_offence = court_application.body["subjectSummary"]["offenceSummary"].first
      court_application.body["subjectSummary"]["offenceSummary"] << first_offence.dup.merge("offenceId" => SecureRandom.uuid)
      court_application.save!
    end

    it "calls the Sqs::MessagePublisher service once" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(Sqs::MessagePublisher).to receive(:call).once

      call_link_creator
    end

    it "calls the CommonPlatform::Api::RecordCourtApplicationLaaReference service multiple times" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .twice
        .with(hash_including(application_reference: "12345678"))

      call_link_creator
    end
  end

  context "with no offences" do
    before do
      court_application.body["subjectSummary"].delete("offenceSummary")
      court_application.save!
    end

    it "calls the Sqs::MessagePublisher service once" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(Sqs::MessagePublisher).to receive(:call).once

      call_link_creator
    end

    it "calls the CommonPlatform::Api::RecordCourtApplicationLaaReference service with no offence ID" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .once
        .with(hash_including(offence_id: nil))

      call_link_creator
    end
  end

  context "when an LaaReference exists" do
    let!(:existing_laa_reference) { LaaReference.create!(defendant_id: SecureRandom.uuid, user_name: "MrDoe", maat_reference:) }

    context "and it is no longer linked" do
      before do
        existing_laa_reference.update!(linked: false)

        allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
          .to receive(:call)
          .and_return(response)
      end

      it "creates an LaaReference" do
        expect {
          call_link_creator
        }.to change(LaaReference, :count).by(1)
      end
    end
  end

  context "with a dummy_maat_reference" do
    let(:maat_reference) { "A10000000" }

    it "does not call the Sqs::MessagePublisher service" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(Sqs::MessagePublisher).not_to receive(:call)

      call_link_creator
    end

    it "creates a dummy maat_reference" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .with(hash_including(application_reference: "A10000000"))

      call_link_creator
    end
  end

  context "with no maat reference" do
    let(:maat_reference) { nil }

    it "creates a dummy_maat_reference" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect(
        described_class.new(subject_id, user_name, maat_reference).laa_reference,
      ).to be_dummy_maat_reference
    end
  end

  describe "linking twice" do
    it "marks previous record as unlinked and creates a new one marked as linked" do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)

      expect {
        described_class.call(subject_id, user_name, maat_reference)
        described_class.call(subject_id, user_name, maat_reference)
      }.to change(LaaReference, :count).by(2)

      expect(LaaReference.where(linked: true).count).to be(1)
    end
  end

  context "when a POST request to Common Platform fails" do
    let(:response) { OpenStruct.new("status" => 500, "success?" => false) }

    before do
      allow(CommonPlatform::Api::RecordCourtApplicationLaaReference)
        .to receive(:call)
        .and_return(response)
    end

    it "raises an error" do
      expect { call_link_creator }.to raise_error "Error posting LAA Reference to Common Platform"
    end

    it "reports to Sentry" do
      expect(Sentry).to receive(:capture_exception) do |_error, options|
        expect(options).to eq({
          tags: {
            request_id: nil,
            subject_id: "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3",
            maat_reference: "12345678",
            user_name: "bob-smith",
            offence_id: "f369a0f5-6faf-43f1-8725-fb79847107cc",
          },
        })
      end

      expect { call_link_creator }.to raise_error StandardError
    end

    it "does not publish to the link created queue" do
      expect(Sqs::MessagePublisher).not_to receive(:call)
      expect { call_link_creator }.to raise_error StandardError
    end
  end
end
