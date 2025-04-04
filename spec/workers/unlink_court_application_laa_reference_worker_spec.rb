require "sidekiq/testing"

RSpec.describe UnlinkCourtApplicationLaaReferenceWorker, type: :worker do
  subject(:work) do
    described_class.perform_async(request_id, subject_id, user_name, unlink_reason_code, unlink_other_reason_text)
  end

  let(:request_id) { "XYZ" }
  let(:subject_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:user_name) { "bob-smith" }
  let(:unlink_reason_code) { 4 }
  let(:unlink_other_reason_text) { "foo" }

  it "queues the job" do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it "calls MaatLinkCreator" do
    Sidekiq::Testing.inline! do
      expect(CourtApplicationLaaReferenceUnlinker).to receive(:call).once.with(
        subject_id:,
        user_name:,
        unlink_reason_code:,
        unlink_other_reason_text:,
      )
      work
    end
  end

  it "sets the request_id on the Current singleton" do
    Sidekiq::Testing.inline! do
      expect(Current).to receive(:set).with(request_id: "XYZ")
      work
    end
  end
end
