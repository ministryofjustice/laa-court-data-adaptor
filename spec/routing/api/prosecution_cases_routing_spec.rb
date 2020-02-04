# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ProsecutionCasesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/prosecution_cases').to route_to('api/prosecution_cases#index')
    end
  end
end
