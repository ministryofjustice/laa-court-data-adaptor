# typed: false
# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "Homebrew.link_args" do
  it_behaves_like "parseable arguments"
end

describe "brew link", :integration_test do
  it "links a given Formula" do
    install_test_formula "testball"
    Formula["testball"].any_installed_keg.unlink

    expect { brew "link", "testball" }
      .to output(/Linking/).to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end
end
