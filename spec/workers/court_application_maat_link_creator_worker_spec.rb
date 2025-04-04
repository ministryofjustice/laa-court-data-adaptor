require "sidekiq/testing"

RSpec.describe CourtApplicationMaatLinkCreatorWorker, type: :worker do
  subject(:work) do
    described_class.perform_async(request_id, subject_id, user_name, maat_reference)
  end

  let(:request_id) { "XYZ" }
  let(:maat_reference) { 12_345_678 }
  let(:subject_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:user_name) { "bob-smith" }

  it "queues the job" do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it "calls MaatLinkCreator" do
    Sidekiq::Testing.inline! do
      expect(CourtApplicationMaatLinkCreator).to receive(:call).once.with(subject_id, user_name, maat_reference)
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
