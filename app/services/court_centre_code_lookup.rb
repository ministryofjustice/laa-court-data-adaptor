# frozen_string_literal: true

class CourtCentreCodeLookup
  CSV_PATH = Rails.root.join("lib/organisation_unit.csv").freeze

  class << self
    def find(id)
      row = csv.find { |r| r["id"] == id }
      row&.fetch("oucode")
    end

  private

    def csv
      @csv ||= CSV.read(CSV_PATH, headers: true)
    end
  end
end
