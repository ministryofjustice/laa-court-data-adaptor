RSpec.describe 'routing', type: :routing do
  it 'routes to #show' do
    expect(get: '/v1/oauth/token/info').to route_to('v1/doorkeeper/token_info#show')
  end

  context 'when no API version is specified' do
    it 'routes to #show' do
      expect(get: '/oauth/token/info').to route_to('v1/doorkeeper/token_info#show')
    end
  end
end
