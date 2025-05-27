require 'rails_helper'

RSpec.describe "recipe_likes#destroy", type: :request do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe) }
  let(:token) { user.token }

  subject(:make_request) do
    jsonapi_delete "/api/v1/recipe_likes/#{like_id}", headers: { 'Authorization': token }
  end

  describe 'sending unauthenticated request' do
    let(:token) { 'invalid token' }
    let(:like_id) { 1 }


    it 'responds with unauthorized' do
      make_request

      expect(response.status).to eq(401)
      expect(response.body).to include('Unauthorized')
    end
  end

  describe 'deleting existing like' do
    let(:like) { create(:recipe_like, user: user, recipe: recipe) }
    let(:like_id) { like.id }

    it 'responds with success and created like' do
      expect(RecipeLikeResource).to receive(:find).and_call_original

      expect { make_request }.to change { RecipeLike.where(user: user, recipe: recipe1).size }.by(-1)

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)). to eq({ 'meta' => {} })
    end
  end

  describe 'deleting non-existing like' do
    before do
      handle_request_exceptions(true)
    end

    let(:like_id) { 1 }

    it 'responds with unprocessable entity' do
      expect(RecipeLikeResource).to receive(:find).and_call_original

      expect { make_request }.not_to change { RecipeLike.where(user: user, recipe: recipe1).size }

      error = JSON.parse(response.body)['errors'].first
      expect(response.status).to eq(404)
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['code']).to eq('not_found')
      expect(error['meta']).to be_present
    end
  end
end
