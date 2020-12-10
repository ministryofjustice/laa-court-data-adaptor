# typed: false
# frozen_string_literal: true

require "rubocops/files"

describe RuboCop::Cop::FormulaAudit::Files do
  subject(:cop) { described_class.new }

  context "When auditing files" do
    it "when the permissions are invalid" do
      filename = Formulary.core_path("test_formula")
      File.open(filename, "w") do |file|
        FileUtils.chmod "-rwx", filename

        expect_offense(<<~RUBY, file)
          class Foo < Formula
          ^^^^^^^^^^^^^^^^^^^ Incorrect file permissions (000): chmod +r #{filename}
            url "https://brew.sh/foo-1.0.tgz"
          end
        RUBY
      end
    end
  end
end
