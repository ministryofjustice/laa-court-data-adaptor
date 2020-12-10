# typed: true
# frozen_string_literal: true

class Formula
  undef on_linux

  def on_linux(&block)
    raise "No block content defined for on_linux block" unless block

    yield
  end

  undef shared_library

  def shared_library(name, version = nil)
    "#{name}.so#{"." unless version.nil?}#{version}"
  end

  class << self
    undef on_linux

    def on_linux(&block)
      raise "No block content defined for on_linux block" unless block

      yield
    end

    undef ignore_missing_libraries

    def ignore_missing_libraries(*libs)
      libraries = libs.flatten
      if libraries.any? { |x| !x.is_a?(String) && !x.is_a?(Regexp) }
        raise FormulaSpecificationError, "#{__method__} can handle Strings and Regular Expressions only"
      end

      allowed_missing_libraries.merge(libraries)
    end
  end
end
