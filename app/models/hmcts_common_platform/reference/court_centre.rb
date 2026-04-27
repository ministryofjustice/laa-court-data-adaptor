# frozen_string_literal: true

require "csv"

module HmctsCommonPlatform
  module Reference
    class CourtCentre
      def self.find(id)
        row = csv.find { |r| r["id"] == id }
        return if row.nil?

        new(row)
      end

      def self.csv
        @csv ||= CSV.read(Rails.root.join("lib/organisation_unit.csv"), headers: true)
      end

      def initialize(row)
        @row = row
      end

      # Organisational Unit Code
      def oucode
        @row["oucode"]
      end
    end
  end
end
