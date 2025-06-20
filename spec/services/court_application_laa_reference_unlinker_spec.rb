RSpec.describe CourtApplicationLaaReferenceUnlinker do
  subject(:call_unlinker) do
    described_class.call(subject_id:,
                         user_name:,
                         unlink_reason_code:,
                         unlink_other_reason_text:,
                         maat_reference:)
  end

  let(:subject_id) { "8cd0ba7e-df89-45a3-8c61-4008a2186d64" }
  let(:application_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:user_name) { "johnDoe" }
  let(:unlink_reason_code) { 1 }
  let(:unlink_other_reason_text) { "Wrong defendant" }
  let(:maat_reference) { "101010" }
  let!(:linked_laa_reference) do
    LaaReference.create(defendant_id: subject_id,
                        user_name: "cpUser",
                        maat_reference:,
                        linked: true)
  end

  before do
    CourtApplication.create!(
      id: application_id,
      body: JSON.parse(file_fixture("court_application_summary.json").read),
    )
    CourtApplicationDefendantOffence.create!(court_application_id: application_id,
                                             defendant_id: subject_id,
                                             offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710",
                                             application_type: "appeal")
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE dummy_maat_reference_seq RESTART;")

    allow(CommonPlatform::Api::RecordCourtApplicationLaaReference).to receive(:call)
    allow(Rails.logger).to receive(:warn)
  end

  it "creates a dummy maat_reference starting with Z" do
    expect(CommonPlatform::Api::RecordCourtApplicationLaaReference).to receive(:call).with(hash_including(application_reference: "Z10000000"))
    call_unlinker
  end

  it "unlinks currently linked LaaReference" do
    call_unlinker
    expect(linked_laa_reference.reload).not_to be_linked
  end

  it "stores the reason code" do
    call_unlinker
    expect(linked_laa_reference.reload.unlink_reason_code).to eq unlink_reason_code
  end

  context "when LaaReference is already unlinked" do
    before do
      linked_laa_reference.update(linked: false)
    end

    it "logs a 'already unlinked' warning message" do
      expect(call_unlinker).to be_nil
    end
  end

  context "when there are multiple references" do
    let!(:other_laa_reference) do
      LaaReference.create(defendant_id: subject_id,
                          user_name: "cpUser",
                          maat_reference: "something_else",
                          linked: true)
    end

    it "unlinks the correct reference" do
      call_unlinker
      expect(other_laa_reference.reload).to be_linked
      expect(linked_laa_reference.reload).not_to be_linked
    end
  end

  context "when LaaReference is linked" do
    it "does not log a warning message" do
      call_unlinker

      expect(Rails.logger).not_to have_received(:warn)
    end
  end

  it "calls the Sqs::MessagePublisher service once" do
    message = {
      defendantId: "8cd0ba7e-df89-45a3-8c61-4008a2186d64",
      maatId: "101010",
      userId: user_name,
      reasonId: unlink_reason_code,
      otherReasonText: unlink_other_reason_text,
    }

    expect(Sqs::MessagePublisher).to receive(:call)
      .once
      .with(
        message:,
        queue_url: Rails.configuration.x.aws.sqs_url_unlink,
        log_info: { maat_reference: "101010" },
      )

    call_unlinker
  end

  context "with multiple offences" do
    before do
      CourtApplicationDefendantOffence.create!(court_application_id: application_id,
                                               defendant_id: subject_id,
                                               offence_id: SecureRandom.uuid,
                                               application_type: "appeal")
    end

    it "calls the Sqs::MessagePublisher service once" do
      message = {
        defendantId: "8cd0ba7e-df89-45a3-8c61-4008a2186d64",
        maatId: "101010",
        userId: user_name,
        reasonId: unlink_reason_code,
        otherReasonText: unlink_other_reason_text,
      }

      expect(Sqs::MessagePublisher).to receive(:call)
        .once
        .with(
          message:,
          queue_url: Rails.configuration.x.aws.sqs_url_unlink,
          log_info: { maat_reference: message[:maatId] },
        )

      call_unlinker
    end

    it "calls the CommonPlatform::Api::RecordProsecutionCaseLaaReference service multiple times" do
      expect(CommonPlatform::Api::RecordCourtApplicationLaaReference).to receive(:call).twice.with(hash_including(application_reference: "Z10000000"))
      call_unlinker
    end
  end

  context "when the maat_reference is a dummy" do
    let(:maat_reference) { "Z10000000" }

    it "does not call the Sqs::MessagePublisher service" do
      expect(Sqs::MessagePublisher).not_to receive(:call)
      call_unlinker
    end

    it "calls the CommonPlatform::Api::RecordProsecutionCaseLaaReference service" do
      expect(CommonPlatform::Api::RecordCourtApplicationLaaReference).to receive(:call).once.with(hash_including(application_reference: "Z10000000"))
      call_unlinker
    end
  end
end
