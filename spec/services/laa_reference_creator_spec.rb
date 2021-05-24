# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe LaaReferenceCreator do
  subject(:create_reference) { described_class.call(maat_reference: maat_reference, user_name: user_name, defendant_id: defendant_id) }

  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { "8cd0ba7e-df89-45a3-8c61-4008a2186d64" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:user_name) { "caseWorker" }

  before do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0],
    )
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710")

    allow(Api::RecordLaaReference).to receive(:call)
    allow(Api::GetHearingResults).to receive(:call)
  end

  it "creates an LaaReference" do
    expect {
      create_reference
    }.to change(LaaReference, :count).by(1)
  end

  it "sets the LaaReference attributes" do
    create_reference
    laa_reference = LaaReference.last
    expect(laa_reference.defendant_id).to eq(defendant_id)
    expect(laa_reference.maat_reference).to eq("12345678")
    expect(laa_reference).not_to be_dummy_maat_reference
  end

  it "returns the LaaReference" do
    expect(create_reference).to be_an(LaaReference)
  end

  it "enqueues a MaatLinkCreatorWorker" do
    Sidekiq::Testing.fake! do
      Current.set(request_id: "XYZ") do
        expect(MaatLinkCreatorWorker).to receive(:perform_async).with("XYZ", String).and_call_original
        create_reference
      end
    end
  end

  context "when an LaaReference exists" do
    let!(:existing_laa_reference) { LaaReference.create!(defendant_id: SecureRandom.uuid, user_name: "MrDoe", maat_reference: maat_reference) }

    it "raises an ActiveRecord::RecordInvalid error" do
      expect {
        create_reference
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context "and it is no longer linked" do
      before do
        existing_laa_reference.update!(linked: false)
      end

      it "creates an LaaReference" do
        expect {
          create_reference
        }.to change(LaaReference, :count).by(1)
      end
    end
  end

  context "with no maat reference" do
    let(:maat_reference) { nil }

    before do
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE dummy_maat_reference_seq RESTART;")
    end

    it "creates a dummy_maat_reference" do
      create_reference
      laa_reference = LaaReference.last

      expect(laa_reference.defendant_id).to eq(defendant_id)
      expect(laa_reference.maat_reference).to eq("A10000000")
      expect(laa_reference).to be_dummy_maat_reference
    end
  end
end
