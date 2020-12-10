# typed: true
# frozen_string_literal: true

require "exceptions"
require "hardware"
require "version"

module OS
  module Mac
    # A macOS version.
    #
    # @api private
    class Version < ::Version
      extend T::Sig

      SYMBOLS = {
        big_sur:     "11",
        catalina:    "10.15",
        mojave:      "10.14",
        high_sierra: "10.13",
        sierra:      "10.12",
        el_capitan:  "10.11",
        yosemite:    "10.10",
      }.freeze

      sig { params(sym: Symbol).returns(T.attached_class) }
      def self.from_symbol(sym)
        @all_archs_regex ||= /^#{Regexp.union(Hardware::CPU::ALL_ARCHS.map(&:to_s))}_/
        sym_without_arch = sym.to_s
                              .sub(@all_archs_regex, "")
                              .to_sym
        str = SYMBOLS.fetch(sym_without_arch) { raise MacOSVersionError, sym }
        new(str)
      end

      sig { params(value: T.nilable(String)).void }
      def initialize(value)
        raise MacOSVersionError, value unless /\A1\d+(?:\.\d+){0,2}\Z/.match?(value)

        super(value)

        @comparison_cache = {}
      end

      def <=>(other)
        @comparison_cache.fetch(other) do
          if SYMBOLS.key?(other) && to_sym == other
            0
          else
            v = SYMBOLS.fetch(other) { other.to_s }
            @comparison_cache[other] = super(::Version.new(v))
          end
        end
      end

      sig { returns(Symbol) }
      def to_sym
        @to_sym ||= begin
          # Big Sur is 11.x but Catalina is 10.15.
          major_macos = if major >= 11
            major
          else
            major_minor
          end.to_s
          SYMBOLS.invert.fetch(major_macos, :dunno)
        end
      end

      sig { returns(String) }
      def pretty_name
        @pretty_name ||= to_sym.to_s.split("_").map(&:capitalize).join(" ").freeze
      end

      # For {OS::Mac::Version} compatibility.
      sig { returns(T::Boolean) }
      def requires_nehalem_cpu?
        unless Hardware::CPU.intel?
          raise "Unexpected architecture: #{Hardware::CPU.arch}. This only works with Intel architecture."
        end

        Hardware.oldest_cpu(self) == :nehalem
      end
      # https://en.wikipedia.org/wiki/Nehalem_(microarchitecture)
      # Ensure any extra methods are also added to version/null.rb
      alias requires_sse4? requires_nehalem_cpu?
      alias requires_sse41? requires_nehalem_cpu?
      alias requires_sse42? requires_nehalem_cpu?
      alias requires_popcnt? requires_nehalem_cpu?
    end
  end
end
