# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  include AuthorisedRequestHelper

  controller do
    def index
      head :ok
    end
  end

  it_behaves_like 'an unauthorised request'

  it 'returns an Laa-Transaction-Id on every request' do
    get :index
    expect(response.headers).to include('Laa-Transaction-Id')
  end

  context 'when the Laa-Transaction-Id is included by an external service' do
    before do
      request.headers['Laa-Transaction-Id'] = 'XYZ'
    end

    it 'returns an Laa-Transaction-Id on every request' do
      get :index
      expect(response.headers['Laa-Transaction-Id']).to eq('XYZ')
    end
  end
end
