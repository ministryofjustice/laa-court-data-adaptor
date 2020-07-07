# frozen_string_literal: true

require 'csv'

module ReferenceData
  class CourtCentreFinder < ApplicationService
    def initialize(id:)
      @id = id
    end

    def call
      csv.find { |row| row['id'] == id }
    end

    private

    def csv
      CSV.read(Rails.root.join('lib/reference_data/organisation_unit.csv'), headers: true)
    end

    attr_reader :id
  end
end
