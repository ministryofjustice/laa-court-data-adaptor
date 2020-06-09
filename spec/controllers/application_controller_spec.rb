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
end
