# typed: false
# frozen_string_literal: true

require "rubocops/dependency_order"

describe RuboCop::Cop::FormulaAudit::DependencyOrder do
  subject(:cop) { described_class.new }

  context "uses_from_macos" do
    it "wrong conditional uses_from_macos order" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos "apple" if build.with? "foo"
          uses_from_macos "foo" => :optional
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ dependency "foo" (line 5) should be put before dependency "apple" (line 4)
        end
      RUBY
    end

    it "wrong alphabetical uses_from_macos order" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos "foo"
          uses_from_macos "bar"
          ^^^^^^^^^^^^^^^^^^^^^ dependency "bar" (line 5) should be put before dependency "foo" (line 4)
        end
      RUBY
    end

    it "supports requirement constants" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos FooRequirement
          uses_from_macos "bar"
          ^^^^^^^^^^^^^^^^^^^^^ dependency "bar" (line 5) should be put before dependency "FooRequirement" (line 4)
        end
      RUBY
    end

    it "wrong conditional uses_from_macos order with block" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          head do
            uses_from_macos "apple" if build.with? "foo"
            uses_from_macos "bar"
            ^^^^^^^^^^^^^^^^^^^^^ dependency "bar" (line 6) should be put before dependency "apple" (line 5)
            uses_from_macos "foo" => :optional
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ dependency "foo" (line 7) should be put before dependency "apple" (line 5)
          end
          uses_from_macos "apple" if build.with? "foo"
          uses_from_macos "foo" => :optional
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ dependency "foo" (line 10) should be put before dependency "apple" (line 9)
        end
      RUBY
    end

    it "correct uses_from_macos order for multiple tags" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos "bar" => [:build, :test]
          uses_from_macos "foo" => :build
          uses_from_macos "apple"
        end
      RUBY
    end
  end

  context "depends_on" do
    it "wrong conditional depends_on order" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          depends_on "apple" if build.with? "foo"
          depends_on "foo" => :optional
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ dependency "foo" (line 5) should be put before dependency "apple" (line 4)
        end
      RUBY
    end

    it "wrong alphabetical depends_on order" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          depends_on "foo"
          depends_on "bar"
          ^^^^^^^^^^^^^^^^ dependency "bar" (line 5) should be put before dependency "foo" (line 4)
        end
      RUBY
    end

    it "supports requirement constants" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          depends_on FooRequirement
          depends_on "bar"
          ^^^^^^^^^^^^^^^^ dependency "bar" (line 5) should be put before dependency "FooRequirement" (line 4)
        end
      RUBY
    end

    it "wrong conditional depends_on order with block" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          head do
            depends_on "apple" if build.with? "foo"
            depends_on "bar"
            ^^^^^^^^^^^^^^^^ dependency "bar" (line 6) should be put before dependency "apple" (line 5)
            depends_on "foo" => :optional
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ dependency "foo" (line 7) should be put before dependency "apple" (line 5)
          end
          depends_on "apple" if build.with? "foo"
          depends_on "foo" => :optional
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ dependency "foo" (line 10) should be put before dependency "apple" (line 9)
        end
      RUBY
    end

    it "correct depends_on order for multiple tags" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          depends_on "bar" => [:build, :test]
          depends_on "foo" => :build
          depends_on "apple"
        end
      RUBY
    end
  end

  context "autocorrect" do
    it "wrong conditional uses_from_macos order" do
      source = <<~RUBY
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos "apple" if build.with? "foo"
          uses_from_macos "foo" => :optional
        end
      RUBY

      correct_source = <<~RUBY
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos "foo" => :optional
          uses_from_macos "apple" if build.with? "foo"
        end
      RUBY

      corrected_source = autocorrect_source(source)
      expect(corrected_source).to eq(correct_source)
    end

    it "wrong conditional depends_on order" do
      source = <<~RUBY
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          depends_on "apple" if build.with? "foo"
          depends_on "foo" => :optional
        end
      RUBY

      correct_source = <<~RUBY
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          depends_on "foo" => :optional
          depends_on "apple" if build.with? "foo"
        end
      RUBY

      corrected_source = autocorrect_source(source)
      expect(corrected_source).to eq(correct_source)
    end
  end
end
