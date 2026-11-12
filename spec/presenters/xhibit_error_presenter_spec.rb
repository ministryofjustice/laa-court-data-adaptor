RSpec.describe XhibitErrorPresenter, type: :presenter do
  describe ".reason_for_error" do
    context "when process_errors is nil" do
      it "returns nil" do
        expect(described_class.reason_for_error(nil)).to be_nil
      end
    end

    context "when process_errors is empty" do
      it "returns nil" do
        expect(described_class.reason_for_error({})).to be_nil
      end
    end
  end

  describe "#reason" do
    context "with MAAT not found error" do
      let(:process_errors) { { "maat" => { "message" => "MAAT application not found" } } }

      it "returns user-friendly message" do
        presenter = described_class.new(process_errors)
        expect(presenter.reason).to eq("MAAT application not found for this defendant")
      end
    end

    context "with MAAT linked to CP error" do
      let(:process_errors) do
        { "maat" => { "message" => "MAAT ID already linked with other CP case (case_urn_123)" } }
      end

      it "returns user-friendly message" do
        presenter = described_class.new(process_errors)
        expect(presenter.reason).to eq("MAAT record is linked to another court case")
      end
    end

    context "with MAAT link status unknown error" do
      let(:process_errors) { { "maat" => { "message" => "MAAT link status could not be determined" } } }

      it "returns user-friendly message" do
        presenter = described_class.new(process_errors)
        expect(presenter.reason).to eq("Cannot verify MAAT record status—manual review needed")
      end
    end

    context "with Common Platform not found error" do
      let(:process_errors) do
        { "common_platform" => { "message" => "Case not found on Common Platform" } }
      end

      it "returns user-friendly message" do
        presenter = described_class.new(process_errors)
        expect(presenter.reason).to eq("Case not found on Common Platform")
      end
    end

    context "with technical errors (should not display)" do
      [
        { "maat" => { "error" => 500, "message" => "Internal Server Error" }, name: "MAAT HTTP error" },
        { "link" => { "message" => "Validation failed: MAAT ID already in use" }, name: "validation error" },
        { "unexpected" => { "error" => "ArgumentError", "message" => "Unsupported case type" }, name: "unexpected error" },
        {
          "maat" => { "message" => "LIBRA unlink requested. The case will be linked once MAAT reports it as unlinked" },
          name: "LIBRA unlink",
        },
      ].each do |errors|
        context "with `#{errors.delete(:name)}` error" do
          let(:process_errors) { errors }

          it "returns nil (don't show technical errors)" do
            presenter = described_class.new(process_errors)
            expect(presenter.reason).to be_nil
          end
        end
      end
    end

    context "with multiple errors (should show MAAT first, then CP)" do
      let(:process_errors) do
        {
          "maat" => { "message" => "MAAT application not found" },
          "link" => { "message" => "Validation failed: something" },
        }
      end

      it "returns reason for MAAT error (primary)" do
        presenter = described_class.new(process_errors)
        expect(presenter.reason).to eq("MAAT application not found for this defendant")
      end
    end
  end
end
