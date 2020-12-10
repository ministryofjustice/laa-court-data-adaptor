# typed: false
# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "Homebrew.__cache_args" do
  it_behaves_like "parseable arguments"
end

describe "brew --cache", :integration_test do
  it "prints all cache files for a given Formula" do
    expect { brew "--cache", testball }
      .to output(%r{#{HOMEBREW_CACHE}/downloads/[\da-f]{64}--testball-}o).to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end

  it "prints the cache files for a given Cask" do
    expect { brew "--cache", cask_path("local-caffeine") }
      .to output(%r{#{HOMEBREW_CACHE}/downloads/[\da-f]{64}--caffeine\.zip}o).to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end

  it "prints the cache files for a given Formula and Cask" do
    expect { brew "--cache", testball, cask_path("local-caffeine") }
      .to output(
        %r{
          #{HOMEBREW_CACHE}/downloads/[\da-f]{64}--testball-.*\n
          #{HOMEBREW_CACHE}/downloads/[\da-f]{64}--caffeine\.zip
        }xo,
      ).to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end
end
