# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/hearings').to route_to('hearings#create')
    end
  end
end
