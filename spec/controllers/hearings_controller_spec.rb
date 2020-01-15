# frozen_string_literal: true

RSpec.describe HearingsController, type: :controller do
  include AuthorisedRequestHelper

  before { authorise_requests! }

  let(:valid_attributes) { JSON.parse(file_fixture('valid_hearing.json').read) }
  let(:invalid_attributes) { JSON.parse(file_fixture('invalid_hearing.json').read) }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Hearing' do
        expect {
          post :create, params: valid_attributes
        }.to change(Hearing, :count).by(1)
      end

      it 'renders a JSON response with an empty response' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(response.body).to be_empty
      end
    end

    context 'with an invalid hearing' do
      it 'renders a JSON response with an unprocessable_entity error' do
        allow(HearingRecorder).to receive(:call).and_return(Hearing.new)
        post :create, params: valid_attributes
        expect(response.body).to include("can't be blank")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new hearing' do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
