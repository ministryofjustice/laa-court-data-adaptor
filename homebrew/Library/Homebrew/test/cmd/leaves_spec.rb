# typed: false
# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "Homebrew.leaves_args" do
  it_behaves_like "parseable arguments"
end

describe "brew leaves", :integration_test do
  context "when there are no installed Formulae" do
    it "prints nothing" do
      setup_test_formula "foo"
      setup_test_formula "bar"

      expect { brew "leaves" }
        .to not_to_output.to_stdout
        .and not_to_output.to_stderr
        .and be_a_success
    end
  end

  context "when there are only installed Formulae without dependencies" do
    it "prints all installed Formulae" do
      setup_test_formula "foo"
      setup_test_formula "bar"
      (HOMEBREW_CELLAR/"foo/0.1/somedir").mkpath

      expect { brew "leaves" }
        .to output("foo\n").to_stdout
        .and not_to_output.to_stderr
        .and be_a_success
    end
  end

  context "when there are installed Formulae" do
    it "prints all installed Formulae that are not dependencies of another installed Formula" do
      setup_test_formula "foo"
      setup_test_formula "bar"
      (HOMEBREW_CELLAR/"foo/0.1/somedir").mkpath
      (HOMEBREW_CELLAR/"bar/0.1/somedir").mkpath

      expect { brew "leaves" }
        .to output("bar\n").to_stdout
        .and not_to_output.to_stderr
        .and be_a_success
    end
  end
end
