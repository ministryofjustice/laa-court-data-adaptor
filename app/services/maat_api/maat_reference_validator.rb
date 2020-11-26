# frozen_string_literal: true

module MaatApi
  class MaatReferenceValidator < ApplicationService
    URL = "link/validate"

    def initialize(maat_reference:, connection: MaatApi::Connection.call)
      @maat_reference = maat_reference
      @connection = connection
    end

    def call
      connection.post(URL, { maatId: maat_reference, caseUrn: "XYZ" }) if connection.present?
    end

  private

    attr_reader :maat_reference, :connection
  end
end
