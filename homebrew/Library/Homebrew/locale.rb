# typed: true
# frozen_string_literal: true

# Representation of a system locale.
#
# Used to compare the system language and languages defined using the cask `language` stanza.
#
# @api private
class Locale
  extend T::Sig

  # Error when a string cannot be parsed to a `Locale`.
  class ParserError < StandardError
  end

  # ISO 639-1 or ISO 639-2
  LANGUAGE_REGEX = /(?:[a-z]{2,3})/.freeze
  private_constant :LANGUAGE_REGEX

  # ISO 3166-1 or UN M.49
  REGION_REGEX = /(?:[A-Z]{2}|\d{3})/.freeze
  private_constant :REGION_REGEX

  # ISO 15924
  SCRIPT_REGEX = /(?:[A-Z][a-z]{3})/.freeze
  private_constant :SCRIPT_REGEX

  LOCALE_REGEX = /\A((?:#{LANGUAGE_REGEX}|#{REGION_REGEX}|#{SCRIPT_REGEX})(?:-|$)){1,3}\Z/.freeze
  private_constant :LOCALE_REGEX

  def self.parse(string)
    if locale = try_parse(string)
      return locale
    end

    raise ParserError, "'#{string}' cannot be parsed to a #{self}"
  end

  sig { params(string: String).returns(T.nilable(T.attached_class)) }
  def self.try_parse(string)
    return if string.blank?

    scanner = StringScanner.new(string)

    if language = scanner.scan(LANGUAGE_REGEX)
      sep = scanner.scan(/-/)
      return if (sep && scanner.eos?) || (sep.nil? && !scanner.eos?)
    end

    if region = scanner.scan(REGION_REGEX)
      sep = scanner.scan(/-/)
      return if (sep && scanner.eos?) || (sep.nil? && !scanner.eos?)
    end

    script = scanner.scan(SCRIPT_REGEX)

    return unless scanner.eos?

    new(language, region, script)
  end

  attr_reader :language, :region, :script

  def initialize(language, region, script)
    raise ArgumentError, "#{self.class} cannot be empty" if language.nil? && region.nil? && script.nil?

    {
      language: language,
      region:   region,
      script:   script,
    }.each do |key, value|
      next if value.nil?

      regex = self.class.const_get("#{key.upcase}_REGEX")
      raise ParserError, "'#{value}' does not match #{regex}" unless value&.match?(regex)

      instance_variable_set(:"@#{key}", value)
    end
  end

  def include?(other)
    unless other.is_a?(self.class)
      other = self.class.try_parse(other)
      return false if other.nil?
    end

    [:language, :region, :script].all? do |var|
      if other.public_send(var).nil?
        true
      else
        public_send(var) == other.public_send(var)
      end
    end
  end

  def eql?(other)
    unless other.is_a?(self.class)
      other = self.class.try_parse(other)
      return false if other.nil?
    end

    [:language, :region, :script].all? do |var|
      public_send(var) == other.public_send(var)
    end
  end
  alias == eql?

  def detect(locale_groups)
    locale_groups.find { |locales| locales.any? { |locale| eql?(locale) } } ||
      locale_groups.find { |locales| locales.any? { |locale| include?(locale) } }
  end

  sig { returns(String) }
  def to_s
    [@language, @region, @script].compact.join("-")
  end
end
