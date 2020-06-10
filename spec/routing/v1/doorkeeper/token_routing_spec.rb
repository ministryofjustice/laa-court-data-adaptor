# frozen_string_literal: true

RSpec.describe 'routing', type: :routing do
  it 'routes to #create' do
    expect(post: '/v1/oauth/token').to route_to('v1/doorkeeper/tokens#create')
  end

  it 'routes to #revoke' do
    expect(post: '/v1/oauth/revoke').to route_to('v1/doorkeeper/tokens#revoke')
  end

  it 'routes to #introspect' do
    expect(post: '/v1/oauth/introspect').to route_to('v1/doorkeeper/tokens#introspect')
  end

  context 'when no API version is specified' do
    it 'routes to #revoke' do
      expect(post: '/oauth/revoke').to route_to('v1/doorkeeper/tokens#revoke')
    end

    it 'routes to #introspect' do
      expect(post: '/oauth/introspect').to route_to('v1/doorkeeper/tokens#introspect')
    end

    it 'routes to #create' do
      expect(post: '/oauth/token').to route_to('v1/doorkeeper/tokens#create')
    end
  end
end
