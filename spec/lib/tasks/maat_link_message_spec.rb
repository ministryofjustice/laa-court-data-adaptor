require "rails_helper"

RSpec.describe "maat_link_message:send task" do
  subject(:send_task) { Rake::Task["maat_link_message:send"].execute }

  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:user_name) { "john.doe" }
  let(:maat_reference) { "12345678" }
  let(:court_centre_id) { "f8254db1-1683-483e-afb3-b87fde5a0a26" }
  let(:oucode) { "B01JQ" }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    allow($stdout).to receive(:puts)
    allow(MaatLinkMessageSender).to receive(:call)
  end

  after { Rake::Task["maat_link_message:send"].reenable }

  context "with all required parameters" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DEFENDANT_ID").and_return(defendant_id)
      allow(ENV).to receive(:[]).with("USER_NAME").and_return(user_name)
      allow(ENV).to receive(:[]).with("MAAT_REFERENCE").and_return(maat_reference)
      allow(ENV).to receive(:[]).with("COURT_CENTRE_ID").and_return(court_centre_id)
      allow(ENV).to receive(:[]).with("OUCODE").and_return(oucode)

      send_task
    end

    it "calls `MaatLinkMessageSender` with correct parameters" do
      expect(MaatLinkMessageSender).to have_received(:call).with(
        defendant_id:,
        user_name:,
        maat_reference:,
        court_centre_id:,
        oucode:,
      )
    end

    it "logs the input parameters" do
      expect($stdout).to have_received(:puts).at_least(:once).with(/Defendant ID: #{defendant_id}/)
      expect($stdout).to have_received(:puts).at_least(:once).with(/User: #{user_name}/)
      expect($stdout).to have_received(:puts).at_least(:once).with(/MAAT Reference: #{maat_reference}/)
      expect($stdout).to have_received(:puts).at_least(:once).with(/Court Centre ID: #{court_centre_id}/)
      expect($stdout).to have_received(:puts).at_least(:once).with(/OUCode: #{oucode}/)
    end

    it "reports a successful message sending" do
      expect($stdout).to have_received(:puts).with(/SUCCESS.*MAAT link message sent successfully.*#{maat_reference}/)
    end

    it "logs the start of the task" do
      expect($stdout).to have_received(:puts).with(/Starting to send MAAT link message/)
    end
  end

  context "when ArgumentError is raised (validation error)" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DEFENDANT_ID").and_return(defendant_id)
      allow(ENV).to receive(:[]).with("USER_NAME").and_return(user_name)
      allow(ENV).to receive(:[]).with("MAAT_REFERENCE").and_return(maat_reference)
      allow(ENV).to receive(:[]).with("COURT_CENTRE_ID").and_return(court_centre_id)
      allow(ENV).to receive(:[]).with("OUCODE").and_return(oucode)

      allow(MaatLinkMessageSender).to receive(:call).and_raise(ArgumentError, "Defendant not found")
    end

    it "logs the validation error" do
      expect { send_task }.to raise_error(SystemExit)
      expect($stdout).to have_received(:puts).with(/ERROR.*Validation error: Defendant not found/)
    end

    it "exits with error code 1" do
      expect { send_task }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end
  end

  context "when `StandardError` is raised (other errors)" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DEFENDANT_ID").and_return(defendant_id)
      allow(ENV).to receive(:[]).with("USER_NAME").and_return(user_name)
      allow(ENV).to receive(:[]).with("MAAT_REFERENCE").and_return(maat_reference)
      allow(ENV).to receive(:[]).with("COURT_CENTRE_ID").and_return(court_centre_id)
      allow(ENV).to receive(:[]).with("OUCODE").and_return(oucode)

      allow(MaatLinkMessageSender).to receive(:call).and_raise(StandardError, "SQS connection error")
    end

    it "logs the error message" do
      expect { send_task }.to raise_error(SystemExit)
      expect($stdout).to have_received(:puts).with(/ERROR.*Failed to send MAAT link message: SQS connection error/)
    end

    it "logs the backtrace" do
      expect { send_task }.to raise_error(SystemExit)
      expect($stdout).to have_received(:puts).with(/spec\/lib\/tasks\/maat_link_message_spec\.rb/)
    end

    it "exits with error code 1" do
      expect { send_task }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end
  end

  context "when missing required parameters (`ArgumentError`)" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DEFENDANT_ID").and_return(nil)
      allow(ENV).to receive(:[]).with("USER_NAME").and_return(user_name)
      allow(ENV).to receive(:[]).with("MAAT_REFERENCE").and_return(maat_reference)
      allow(ENV).to receive(:[]).with("COURT_CENTRE_ID").and_return(court_centre_id)
      allow(ENV).to receive(:[]).with("OUCODE").and_return(oucode)

      allow(MaatLinkMessageSender).to receive(:call).and_raise(ArgumentError, "defendant_id is required")
    end

    it "exits with error code 1" do
      expect { send_task }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it "logs the validation error" do
      expect { send_task }.to raise_error(SystemExit)
      expect($stdout).to have_received(:puts).with(/ERROR.*defendant_id is required/)
    end
  end
end
