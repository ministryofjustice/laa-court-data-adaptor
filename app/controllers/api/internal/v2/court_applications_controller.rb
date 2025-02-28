# frozen_string_literal: true

module Api
  module Internal
    module V2
      class CourtApplicationsController < ApplicationController
        def show
          # TODO: this is a temporary implementation
          # the real implementation will return the court application details
          # retrieved from the Common Platform API
          court_application_details_sample = JSON.parse(
            File.read("spec/fixtures/files/court_application_details/all_fields.json"),
          )
          render json: court_application_details_sample
        end
      end
    end
  end
end
