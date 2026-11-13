# frozen_string_literal: true

RSpec.describe LinkLargeCaseWithThrottling do
  subject(:link_case) do
    described_class.call(
      maat_reference:,
      user_name:,
      prosecution_case_urn:,
    )
  end

  let(:maat_reference) { "8597508" }
  let(:user_name) { "jane.smith" }
  let(:prosecution_case_urn) { "13LD1319422" }
  let(:defendant_id) { "d5e6f7a8-b9c0-d1e2-f3a4-b5c6d7e8f9a0" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:offence_ids) do
    (1..110).map { |i| "offence-#{i}-#{SecureRandom.uuid}" }
  end

  before do
    # Create prosecution case with URN
    create(:prosecution_case,
           id: prosecution_case_id,
           body: {
             prosecutionCaseReference: prosecution_case_urn,
             defendantSummary: [{ defendantId: defendant_id }],
             hearingSummary: [],
           })

    # Create 110 offences for the defendant
    offence_ids.each do |offence_id|
      create(:prosecution_case_defendant_offence,
             prosecution_case_id:,
             defendant_id:,
             offence_id:)
    end

    allow(CommonPlatform::Api::RecordProsecutionCaseLaaReference).to receive(:call)
                                                                  .and_return(double(success?: true))
    allow(Sqs::MessagePublisher).to receive(:call)
    allow(Sentry).to receive(:capture_exception)
  end

  context "with 110 offences" do
    it "links all offences to Common Platform with delays between requests" do
      expect(CommonPlatform::Api::RecordProsecutionCaseLaaReference).to receive(:call).exactly(110).times

      start_time = Time.zone.now
      link_case
      end_time = Time.zone.now
      duration = end_time - start_time

      # With 110 offences and 1 second delay between each, we expect at least 109 seconds
      # (109 delays of 1 second, plus some overhead for the API calls)
      expect(duration).to be >= 109
    end

    it "publishes a message to the MAAT queue after linking offences" do
      link_case

      expect(Sqs::MessagePublisher).to have_received(:call)
                                     .with(hash_including(
                                             queue_url: Rails.configuration.x.aws.sqs_url_link,
                                           ))
    end

    it "marks the LAA reference as linked" do
      link_case

      laa_reference = LaaReference.find_by(maat_reference:, defendant_id:)
      expect(laa_reference).to be_linked
    end

    context "when an offence linking fails" do
      before do
        call_count = 0
        allow(CommonPlatform::Api::RecordProsecutionCaseLaaReference).to receive(:call) do |args|
          call_count += 1
          if call_count == 5
            double(success?: false, status: 429, body: "Rate limited")
          else
            double(success?: true)
          end
        end
      end

      it "raises an error and captures it with Sentry" do
        expect { link_case }.to raise_error(CommonPlatform::Api::Errors::FailedDependency)
        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end

  context "when prosecution case is not found" do
    before do
      ProsecutionCase.destroy_all
    end

    it "raises an error" do
      expect { link_case }.to raise_error(/Prosecution case not found/)
    end
  end

  context "when no defendants are found for the case" do
    before do
      ProsecutionCaseDefendantOffence.destroy_all
    end

    it "raises an error" do
      expect { link_case }.to raise_error(/No defendants found/)
    end
  end
end
