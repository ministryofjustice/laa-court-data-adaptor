# frozen_string_literal: true

RSpec.describe LaaReferenceUnlinker do
  subject(:create_unlinker) { described_class.call(defendant_id: defendant_id, user_name: user_name, unlink_reason_code: unlink_reason_code, unlink_other_reason_text: unlink_other_reason_text) }

  let(:defendant_id) { "8cd0ba7e-df89-45a3-8c61-4008a2186d64" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:user_name) { "johnDoe" }
  let(:unlink_reason_code) { 1 }
  let(:unlink_other_reason_text) { "Wrong defendant" }
  let!(:linked_laa_reference) { LaaReference.create(defendant_id: defendant_id, user_name: "cpUser", maat_reference: 101_010) }

  before do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0],
    )
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710")
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE dummy_maat_reference_seq RESTART;")
    allow(Api::RecordLaaReference).to receive(:call)
  end

  it "creates a dummy maat_reference starting with Z" do
    expect(Api::RecordLaaReference).to receive(:call).with(hash_including(application_reference: "Z10000000"))
    create_unlinker
  end

  it "unlinks currently linked LaaReference" do
    create_unlinker
    expect(linked_laa_reference.reload).not_to be_linked
  end

  it "calls the Sqs::PublishUnlinkLaaReference service once" do
    expect(Sqs::PublishUnlinkLaaReference).to receive(:call)
      .once
      .with(maat_reference: "101010",
            user_name: user_name,
            unlink_reason_code: unlink_reason_code,
            unlink_other_reason_text: unlink_other_reason_text)
    create_unlinker
  end

  context "with multiple offences" do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it "calls the Sqs::PublishUnlinkLaaReference service once" do
      expect(Sqs::PublishUnlinkLaaReference).to receive(:call)
        .once
        .with(maat_reference: "101010",
              user_name: user_name,
              unlink_reason_code: unlink_reason_code,
              unlink_other_reason_text: unlink_other_reason_text)
      create_unlinker
    end

    it "calls the Api::RecordLaaReference service multiple times" do
      expect(Api::RecordLaaReference).to receive(:call).twice.with(hash_including(application_reference: "Z10000000"))
      create_unlinker
    end
  end

  context "when the maat_reference is a dummy" do
    before do
      linked_laa_reference.update!(dummy_maat_reference: true)
    end

    it "does not call the Sqs::PublishUnlinkLaaReference service" do
      expect(Sqs::PublishUnlinkLaaReference).not_to receive(:call)
      create_unlinker
    end

    it "calls the Api::RecordLaaReference service" do
      expect(Api::RecordLaaReference).to receive(:call).once.with(hash_including(application_reference: "Z10000000"))
      create_unlinker
    end
  end
end
