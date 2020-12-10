# typed: false
# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "Homebrew.fetch_args" do
  it_behaves_like "parseable arguments"
end

describe "brew fetch", :integration_test do
  it "downloads the Formula's URL" do
    setup_test_formula "testball"

    expect { brew "fetch", "testball" }.to be_a_success

    expect(HOMEBREW_CACHE/"testball--0.1.tbz").to be_a_symlink
    expect(HOMEBREW_CACHE/"testball--0.1.tbz").to exist
  end
end
