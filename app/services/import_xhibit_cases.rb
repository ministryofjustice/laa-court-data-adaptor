require "csv"

class ImportXhibitCases < ApplicationService
  def initialize(file_path:)
    @file_path = file_path
  end

  def call
    CSV.foreach(file_path, headers: true) do |row|
      XhibitCase.create!(row.to_h.transform_values(&:presence))
    end
  end

private

  attr_reader :file_path
end
