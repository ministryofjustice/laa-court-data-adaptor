# frozen_string_literal: true

require "rails_helper"

RSpec.describe "case_links tasks" do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    allow($stdout).to receive(:puts)
  end

  describe "case_links:unlink task" do
    subject(:unlink_task) { Rake::Task["case_links:unlink"].execute }

    let(:maat_id) { "1234567" }
    let(:unlink_reason) { "2" }
    let(:defendant_id) { "d5e6f7a8-b9c0-d1e2-f3a4-b5c6d7e8f9a0" }
    let(:laa_reference) do
      create(:laa_reference, maat_reference: maat_id, linked: true, defendant_id:)
    end

    after { Rake::Task["case_links:unlink"].reenable }

    context "with valid params" do
      before do
        laa_reference
        ARGV.replace(["case_links:unlink", maat_id, unlink_reason])
        allow(LaaReferenceUnlinker).to receive(:call)
      end

      it "logs the starting message" do
        unlink_task

        expect($stdout).to have_received(:puts).with(/About to process unlinking of MAAT ID: #{maat_id}/)
      end

      it "finds the LAA reference by MAAT ID" do
        unlink_task

        expect(LaaReference.find_by(maat_reference: maat_id)).to be_present
      end

      it "logs the defendant link removal" do
        unlink_task

        expect($stdout).to have_received(:puts).with(/Removing link between MAAT ID #{maat_id} and Defendant ID #{defendant_id}/)
      end

      it "calls the `LaaReferenceUnlinker` service" do
        unlink_task

        expect(LaaReferenceUnlinker).to have_received(:call)
                                        .with(
                                          hash_including(
                                            defendant_id:,
                                            user_name: "CDA-MANUAL",
                                            unlink_reason_code: unlink_reason,
                                          ),
                                        )
      end

      it "sets up request context" do
        allow(Current).to receive(:set).and_call_original

        unlink_task

        expect(Current).to have_received(:set).with(hash_including(request_id: instance_of(String)))
      end
    end

    context "when LAA reference is not found" do
      before do
        ARGV.replace(["case_links:unlink", "999999999", unlink_reason])
      end

      it "logs an error message" do
        unlink_task

        expect($stdout).to have_received(:puts).with(/There was an error unlinking MAAT ID: 999999999/)
      end
    end

    context "when an exception occurs during unlinking" do
      before do
        laa_reference
        ARGV.replace(["case_links:unlink", maat_id, unlink_reason])
        allow(LaaReferenceUnlinker).to receive(:call).and_raise(StandardError.new("Test error"))
      end

      it "logs the error message" do
        unlink_task

        expect($stdout).to have_received(:puts).with(/There was an error unlinking MAAT ID: #{maat_id}.*Test error/)
      end
    end
  end

  describe "case_links:link_large_case task" do
    subject(:link_large_case_task) { Rake::Task["case_links:link_large_case"].execute }

    let(:maat_reference) { "8597508" }
    let(:user_name) { "jane.smith" }
    let(:prosecution_case_urn) { "13LD1319422" }
    let(:defendant_id) { "d5e6f7a8-b9c0-d1e2-f3a4-b5c6d7e8f9a0" }
    let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }

    after { Rake::Task["case_links:link_large_case"].reenable }

    context "with valid params" do
      before do
        create(:prosecution_case,
               id: prosecution_case_id,
               body: {
                 prosecutionCaseReference: prosecution_case_urn,
                 defendantSummary: [{ defendantId: defendant_id }],
                 hearingSummary: [],
               })

        create(:prosecution_case_defendant_offence,
               prosecution_case_id:,
               defendant_id:)

        ARGV.replace(["case_links:link_large_case", maat_reference, user_name, prosecution_case_urn])
        allow(LinkLargeCaseWithThrottling).to receive(:call)
      end

      it "logs the starting message" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Starting large case linking process/)
      end

      it "logs the case details" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/MAAT Reference: #{maat_reference}, User: #{user_name}, Case URN: #{prosecution_case_urn}/)
      end

      it "calls the `LinkLargeCaseWithThrottling` service" do
        link_large_case_task

        expect(LinkLargeCaseWithThrottling).to have_received(:call)
                                             .with(
                                               maat_reference:,
                                               user_name:,
                                               prosecution_case_urn:,
                                             )
      end

      it "sets up request context" do
        allow(Current).to receive(:set).and_call_original

        link_large_case_task

        expect(Current).to have_received(:set).with(hash_including(request_id: instance_of(String)))
      end

      it "logs success message" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Successfully linked case #{prosecution_case_urn} to MAAT ID #{maat_reference}/)
      end
    end

    context "with missing MAAT reference" do
      before do
        ARGV.replace(["case_links:link_large_case", "", user_name, prosecution_case_urn])
      end

      it "logs error for missing params" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Missing required arguments/)
      end

      it "logs the correct usage example" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Usage: rake case_links:link_large_case MAAT_ID USER_NAME CASE_URN/)
      end
    end

    context "with missing user name" do
      before do
        ARGV.replace(["case_links:link_large_case", maat_reference, "", prosecution_case_urn])
      end

      it "logs error for missing params" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Missing required arguments/)
      end
    end

    context "with missing case URN" do
      before do
        ARGV.replace(["case_links:link_large_case", maat_reference, user_name, ""])
      end

      it "logs error for missing params" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Missing required arguments/)
      end
    end

    context "when `LinkLargeCaseWithThrottling` raises an error" do
      before do
        create(:prosecution_case,
               id: prosecution_case_id,
               body: {
                 prosecutionCaseReference: prosecution_case_urn,
                 defendantSummary: [{ defendantId: defendant_id }],
                 hearingSummary: [],
               })

        create(:prosecution_case_defendant_offence,
               prosecution_case_id:,
               defendant_id:)

        ARGV.replace(["case_links:link_large_case", maat_reference, user_name, prosecution_case_urn])
        allow(LinkLargeCaseWithThrottling).to receive(:call).and_raise(StandardError.new("Connection failed"))
      end

      it "logs the error message" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Failed to link case: Connection failed/)
      end

      it "logs the backtrace" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/case_links_spec\.rb/)
      end
    end

    context "with all three params provided" do
      before do
        create(:prosecution_case,
               id: prosecution_case_id,
               body: {
                 prosecutionCaseReference: prosecution_case_urn,
                 defendantSummary: [{ defendantId: defendant_id }],
                 hearingSummary: [],
               })

        create(:prosecution_case_defendant_offence,
               prosecution_case_id:,
               defendant_id:)

        ARGV.replace(["case_links:link_large_case", maat_reference, user_name, prosecution_case_urn])
        allow(LinkLargeCaseWithThrottling).to receive(:call)
      end

      it "successfully executes the task" do
        expect { link_large_case_task }.not_to raise_error
      end

      it "passes all params correctly to the service" do
        link_large_case_task

        expect(LinkLargeCaseWithThrottling).to have_received(:call).with(
          maat_reference: "8597508",
          user_name: "jane.smith",
          prosecution_case_urn: "13LD1319422",
        )
      end
    end
  end
end
