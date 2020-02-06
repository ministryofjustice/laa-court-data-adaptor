# frozen_string_literal: true

RSpec.describe ProsecutionCasesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/prosecution_cases').to route_to('prosecution_cases#index')
    end
  end
end
