# typed: false
# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "Homebrew.edit_args" do
  it_behaves_like "parseable arguments"
end

describe "brew edit", :integration_test do
  it "opens a given Formula in an editor" do
    HOMEBREW_REPOSITORY.cd do
      system "git", "init"
    end

    setup_test_formula "testball"

    expect { brew "edit", "testball", "HOMEBREW_EDITOR" => "/bin/cat" }
      .to output(/# something here/).to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end
end
