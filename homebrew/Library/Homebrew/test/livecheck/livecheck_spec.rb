# typed: false
# Frozen_string_literal: true

require "livecheck/livecheck"

describe Homebrew::Livecheck do
  subject(:livecheck) { described_class }

  let(:f) do
    formula("test") do
      desc "Test formula"
      homepage "https://brew.sh"
      url "https://brew.sh/test-0.0.1.tgz"
      head "https://github.com/Homebrew/brew.git"

      livecheck do
        url "https://formulae.brew.sh/api/formula/ruby.json"
        regex(/"stable":"(\d+(?:\.\d+)+)"/i)
      end
    end
  end

  let(:f_deprecated) do
    formula("test_deprecated") do
      desc "Deprecated test formula"
      homepage "https://brew.sh"
      url "https://brew.sh/test-0.0.1.tgz"
      deprecate! because: :unmaintained
    end
  end

  let(:f_disabled) do
    formula("test_disabled") do
      desc "Disabled test formula"
      homepage "https://brew.sh"
      url "https://brew.sh/test-0.0.1.tgz"
      disable! because: :unmaintained
    end
  end

  let(:f_gist) do
    formula("test_gist") do
      desc "Gist test formula"
      homepage "https://brew.sh"
      url "https://gist.github.com/Homebrew/0000000000"
    end
  end

  let(:f_head_only) do
    formula("test_head_only") do
      desc "HEAD-only test formula"
      homepage "https://brew.sh"
      head "https://github.com/Homebrew/brew.git"
    end
  end

  let(:f_skip) do
    formula("test_skip") do
      desc "Skipped test formula"
      homepage "https://brew.sh"
      url "https://brew.sh/test-0.0.1.tgz"

      livecheck do
        skip "Not maintained"
      end
    end
  end

  let(:f_versioned) do
    formula("test@0.0.1") do
      desc "Versioned test formula"
      homepage "https://brew.sh"
      url "https://brew.sh/test-0.0.1.tgz"
    end
  end

  let(:args) { double("livecheck_args", full_name?: false, json?: false, quiet?: false, verbose?: true) }

  describe "::formula_name" do
    it "returns the name of the formula" do
      expect(livecheck.formula_name(f, args: args)).to eq("test")
    end

    it "returns the full name" do
      allow(args).to receive(:full_name?).and_return(true)

      expect(livecheck.formula_name(f, args: args)).to eq("test")
    end
  end

  describe "::status_hash" do
    it "returns a hash containing the livecheck status" do
      expect(livecheck.status_hash(f, "error", ["Unable to get versions"], args: args))
        .to eq({
                 formula:  "test",
                 status:   "error",
                 messages: ["Unable to get versions"],
                 meta:     {
                   livecheckable: true,
                 },
               })
    end
  end

  describe "::skip_conditions" do
    it "skips a deprecated formula without a livecheckable" do
      expect { livecheck.skip_conditions(f_deprecated, args: args) }
        .to output("test_deprecated : deprecated\n").to_stdout
        .and not_to_output.to_stderr
    end

    it "skips a disabled formula without a livecheckable" do
      expect { livecheck.skip_conditions(f_disabled, args: args) }
        .to output("test_disabled : disabled\n").to_stdout
        .and not_to_output.to_stderr
    end

    it "skips a versioned formula without a livecheckable" do
      expect { livecheck.skip_conditions(f_versioned, args: args) }
        .to output("test@0.0.1 : versioned\n").to_stdout
        .and not_to_output.to_stderr
    end

    it "skips a HEAD-only formula if not installed" do
      expect { livecheck.skip_conditions(f_head_only, args: args) }
        .to output("test_head_only : HEAD only formula must be installed to be livecheckable\n").to_stdout
        .and not_to_output.to_stderr
    end

    it "skips a formula with a GitHub Gist stable URL" do
      expect { livecheck.skip_conditions(f_gist, args: args) }
        .to output("test_gist : skipped - Stable URL is a GitHub Gist\n").to_stdout
        .and not_to_output.to_stderr
    end

    it "skips a formula with a skip livecheckable" do
      expect { livecheck.skip_conditions(f_skip, args: args) }
        .to output("test_skip : skipped - Not maintained\n").to_stdout
        .and not_to_output.to_stderr
    end

    it "returns false for a non-skippable formula" do
      expect(livecheck.skip_conditions(f, args: args)).to eq(false)
    end
  end

  describe "::checkable_urls" do
    it "returns the list of URLs to check" do
      expect(livecheck.checkable_urls(f))
        .to eq(
          ["https://github.com/Homebrew/brew.git", "https://brew.sh/test-0.0.1.tgz", "https://brew.sh"],
        )
    end
  end

  describe "::preprocess_url" do
    let(:github_git_url_with_extension) { "https://github.com/Homebrew/brew.git" }

    it "returns the unmodified URL for an unparseable URL" do
      # Modeled after the `head` URL in the `ncp` formula
      expect(livecheck.preprocess_url(":something:cvs:@cvs.brew.sh:/cvs"))
        .to eq(":something:cvs:@cvs.brew.sh:/cvs")
    end

    it "returns the unmodified URL for a GitHub URL ending in .git" do
      expect(livecheck.preprocess_url(github_git_url_with_extension))
        .to eq(github_git_url_with_extension)
    end

    it "returns the Git repository URL for a GitHub URL not ending in .git" do
      expect(livecheck.preprocess_url("https://github.com/Homebrew/brew"))
        .to eq(github_git_url_with_extension)
    end

    it "returns the unmodified URL for a GitHub /releases/latest URL" do
      expect(livecheck.preprocess_url("https://github.com/Homebrew/brew/releases/latest"))
        .to eq("https://github.com/Homebrew/brew/releases/latest")
    end

    it "returns the Git repository URL for a GitHub AWS URL" do
      expect(livecheck.preprocess_url("https://github.s3.amazonaws.com/downloads/Homebrew/brew/1.0.0.tar.gz"))
        .to eq(github_git_url_with_extension)
    end

    it "returns the Git repository URL for a github.com/downloads/... URL" do
      expect(livecheck.preprocess_url("https://github.com/downloads/Homebrew/brew/1.0.0.tar.gz"))
        .to eq(github_git_url_with_extension)
    end

    it "returns the Git repository URL for a GitHub tag archive URL" do
      expect(livecheck.preprocess_url("https://github.com/Homebrew/brew/archive/1.0.0.tar.gz"))
        .to eq(github_git_url_with_extension)
    end

    it "returns the Git repository URL for a GitHub release archive URL" do
      expect(livecheck.preprocess_url("https://github.com/Homebrew/brew/releases/download/1.0.0/brew-1.0.0.tar.gz"))
        .to eq(github_git_url_with_extension)
    end

    it "returns the Git repository URL for a gitlab.com archive URL" do
      expect(livecheck.preprocess_url("https://gitlab.com/Homebrew/brew/-/archive/1.0.0/brew-1.0.0.tar.gz"))
        .to eq("https://gitlab.com/Homebrew/brew.git")
    end

    it "returns the Git repository URL for a self-hosted GitLab archive URL" do
      expect(livecheck.preprocess_url("https://brew.sh/Homebrew/brew/-/archive/1.0.0/brew-1.0.0.tar.gz"))
        .to eq("https://brew.sh/Homebrew/brew.git")
    end

    it "returns the Git repository URL for a Codeberg archive URL" do
      expect(livecheck.preprocess_url("https://codeberg.org/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
        .to eq("https://codeberg.org/Homebrew/brew.git")
    end

    it "returns the Git repository URL for a Gitea archive URL" do
      expect(livecheck.preprocess_url("https://gitea.com/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
        .to eq("https://gitea.com/Homebrew/brew.git")
    end

    it "returns the Git repository URL for an Opendev archive URL" do
      expect(livecheck.preprocess_url("https://opendev.org/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
        .to eq("https://opendev.org/Homebrew/brew.git")
    end

    it "returns the Git repository URL for a tildegit archive URL" do
      expect(livecheck.preprocess_url("https://tildegit.org/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
        .to eq("https://tildegit.org/Homebrew/brew.git")
    end

    it "returns the Git repository URL for a LOL Git archive URL" do
      expect(livecheck.preprocess_url("https://lolg.it/Homebrew/brew/archive/brew-1.0.0.tar.gz"))
        .to eq("https://lolg.it/Homebrew/brew.git")
    end

    it "returns the Git repository URL for a sourcehut archive URL" do
      expect(livecheck.preprocess_url("https://git.sr.ht/~Homebrew/brew/archive/1.0.0.tar.gz"))
        .to eq("https://git.sr.ht/~Homebrew/brew")
    end
  end
end
