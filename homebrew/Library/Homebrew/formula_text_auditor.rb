# typed: true
# frozen_string_literal: true

module Homebrew
  # Auditor for checking common violations in {Formula} text content.
  #
  # @api private
  class FormulaTextAuditor
    def initialize(path)
      @text = path.open("rb", &:read)
      @lines = @text.lines.to_a
    end

    def without_patch
      @text.split("\n__END__").first
    end

    def trailing_newline?
      /\Z\n/ =~ @text
    end

    def =~(other)
      other =~ @text
    end

    def include?(s)
      @text.include? s
    end

    def line_number(regex, skip = 0)
      index = @lines.drop(skip).index { |line| line =~ regex }
      index ? index + 1 : nil
    end

    def reverse_line_number(regex)
      index = @lines.reverse.index { |line| line =~ regex }
      index ? @lines.count - index : nil
    end
  end
end
