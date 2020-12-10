# typed: false
# frozen_string_literal: true

require "utils/svn"

describe Utils::Svn do
  before do
    described_class.clear_version_cache
  end

  describe "::available?" do
    it "returns svn version if svn available" do
      if quiet_system "#{HOMEBREW_SHIMS_PATH}/scm/svn", "--version"
        expect(described_class).to be_available
      else
        expect(described_class).not_to be_available
      end
    end
  end

  describe "::version" do
    it "returns svn version if svn available" do
      if quiet_system "#{HOMEBREW_SHIMS_PATH}/scm/svn", "--version"
        expect(described_class.version).to match(/^\d+\.\d+\.\d+$/)
      else
        expect(described_class.version).to be_nil
      end
    end

    it "returns version of svn when svn is available", :needs_svn do
      expect(described_class.version).not_to be_nil
    end
  end

  describe "::remote_exists?" do
    it "returns true when svn is not available" do
      allow(described_class).to receive(:available?).and_return(false)
      expect(described_class).to be_remote_exists("blah")
    end

    context "when svn is available" do
      before do
        allow(described_class).to receive(:available?).and_return(true)
      end

      it "returns false when remote does not exist" do
        expect(described_class).not_to be_remote_exists("blah")
      end

      it "returns true when remote exists", :needs_network, :needs_svn do
        expect(described_class).to be_remote_exists("https://github.com/Homebrew/install")
      end
    end
  end
end
