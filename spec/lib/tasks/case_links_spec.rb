# frozen_string_literal: true

require "rails_helper"

RSpec.describe "case_links tasks" do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    allow($stdout).to receive(:puts)
  end

  describe "case_links:link_prosecution_case_with_many_offences task" do
    subject(:link_large_case_task) { Rake::Task["case_links:link_prosecution_case_with_many_offences"].execute }

    let(:maat_reference) { "1234567" }
    let(:user_name) { "peter" }
    let(:defendant_id) { "d5e6f7a8-b9c0-d1e2-f3a4-b5c6d7e8f9a0" }
    let(:contract_result) { instance_double(Dry::Validation::Result, success?: true) }
    let(:contract) { instance_double(ProsecutionCaseLaaReferenceContract, call: contract_result) }

    before do
      stub_const("ENV", ENV.to_h.merge("MAAT_ID" => maat_reference, "USER_NAME" => user_name, "DEFENDANT_ID" => defendant_id))
      allow(ProsecutionCaseLaaReferenceContract).to receive(:new).and_return(contract)
      allow(ProsecutionCaseMaatLinkCreator).to receive(:call)
    end

    after { Rake::Task["case_links:link_prosecution_case_with_many_offences"].reenable }

    context "with valid params" do
      it "validates the params with the same contract as the API" do
        link_large_case_task

        expect(contract).to have_received(:call).with(maat_reference:, user_name:, defendant_id:)
      end

      it "calls `ProsecutionCaseMaatLinkCreator` with a 1 second offence delay" do
        link_large_case_task

        expect(ProsecutionCaseMaatLinkCreator).to have_received(:call)
          .with(defendant_id, user_name, maat_reference, offence_delay: 1)
      end

      it "sets up request context" do
        allow(Current).to receive(:set).and_call_original

        link_large_case_task

        expect(Current).to have_received(:set).with(hash_including(request_id: instance_of(String)))
      end

      it "logs success message" do
        link_large_case_task

        expect($stdout).to have_received(:puts).with(/Successfully linked defendant #{defendant_id} to MAAT ID #{maat_reference}/)
      end
    end

    context "with a missing argument" do
      let(:user_name) { "" }

      it "logs the usage and exits" do
        expect { link_large_case_task }.to raise_error(SystemExit)

        expect($stdout).to have_received(:puts).with(/Usage: rake case_links:link_prosecution_case_with_many_offences MAAT_ID=1234567 USER_NAME=peter DEFENDANT_ID=<uuid>/)
      end

      it "does not link" do
        expect { link_large_case_task }.to raise_error(SystemExit)

        expect(ProsecutionCaseMaatLinkCreator).not_to have_received(:call)
      end
    end

    context "when the contract fails" do
      let(:contract_result) do
        instance_double(Dry::Validation::Result, success?: false, errors: instance_double(Dry::Validation::MessageSet, to_hash: { maat_reference: ["not found"] }))
      end

      it "logs the error and exits without linking" do
        expect { link_large_case_task }.to raise_error(SystemExit)

        expect($stdout).to have_received(:puts).with(/Failed to link defendant: Contract failed with/)
        expect(ProsecutionCaseMaatLinkCreator).not_to have_received(:call)
      end
    end

    context "when the link creator raises an error" do
      before { allow(ProsecutionCaseMaatLinkCreator).to receive(:call).and_raise(StandardError, "Connection failed") }

      it "logs the error message and exits" do
        expect { link_large_case_task }.to raise_error(SystemExit)

        expect($stdout).to have_received(:puts).with(/Failed to link defendant: Connection failed/)
      end
    end
  end
end
