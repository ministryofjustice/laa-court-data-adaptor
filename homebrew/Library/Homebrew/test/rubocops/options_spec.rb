# typed: false
# frozen_string_literal: true

require "rubocops/options"

describe RuboCop::Cop::FormulaAudit::Options do
  subject(:cop) { described_class.new }

  context "When auditing options" do
    it "reports an offense when using the 32-bit option" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url 'https://brew.sh/foo-1.0.tgz'
          option "with-32-bit"
                       ^^^^^^ macOS has been 64-bit only since 10.6 so 32-bit options are deprecated.
        end
      RUBY
    end

    it "with universal" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url 'https://brew.sh/foo-1.0.tgz'
          option :universal
          ^^^^^^^^^^^^^^^^^ macOS has been 64-bit only since 10.6 so universal options are deprecated.
        end
      RUBY
    end

    it "with bad option names" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url 'https://brew.sh/foo-1.0.tgz'
          option :cxx11
          option "examples", "with-examples"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Options should begin with with/without. Migrate '--examples' with `deprecated_option`.
        end
      RUBY
    end

    it "with without-check option name" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url 'https://brew.sh/foo-1.0.tgz'
          option "without-check"
          ^^^^^^^^^^^^^^^^^^^^^^ Use '--without-test' instead of '--without-check'. Migrate '--without-check' with `deprecated_option`.
        end
      RUBY
    end

    it "with deprecated_optionss" do
      expect_offense(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          url 'https://brew.sh/foo-1.0.tgz'
          deprecated_option "examples" => "with-examples"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Formulae in homebrew/core should not use `deprecated_option`.
        end
      RUBY
    end

    it "with options" do
      expect_offense(<<~RUBY, "/homebrew-core/")
        class Foo < Formula
          url 'https://brew.sh/foo-1.0.tgz'
          option "with-examples"
          ^^^^^^^^^^^^^^^^^^^^^^ Formulae in homebrew/core should not use `option`.
        end
      RUBY
    end
  end
end
