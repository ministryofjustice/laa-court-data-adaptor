# typed: false
# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "Homebrew.options_args" do
  it_behaves_like "parseable arguments"
end

describe "brew options", :integration_test do
  it "prints a given Formula's options" do
    setup_test_formula "testball", <<~RUBY
      depends_on "bar" => :recommended
    RUBY

    expect { brew "options", "testball" }
      .to output("--with-foo\n\tBuild with foo\n--without-bar\n\tBuild without bar support\n\n").to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end
end
