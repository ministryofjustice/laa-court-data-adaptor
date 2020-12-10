# typed: false
# frozen_string_literal: true

require "cmd/search"
require "cmd/shared_examples/args_parse"

describe "Homebrew.search_args" do
  it_behaves_like "parseable arguments"
end

describe "brew search", :integration_test do
  it "falls back to a GitHub tap search when no formula is found", :needs_macos, :needs_network do
    setup_test_formula "testball"
    setup_remote_tap "homebrew/cask"

    expect { brew "search", "homebrew/cask/firefox" }
      .to output(/firefox/).to_stdout
      .and be_a_success
  end

  # doesn't actually need Linux but only want one integration test per-OS.
  it "finds formula in search", :need_linux do
    setup_test_formula "testball"

    expect { brew "search", "testball" }
      .to output(/testball/).to_stdout
      .and be_a_success
  end
end
