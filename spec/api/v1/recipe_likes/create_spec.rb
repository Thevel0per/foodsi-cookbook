require 'rails_helper'

RSpec.describe "recipe_likes#create", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.token }

  subject(:make_request) do
    jsonapi_post "/api/v1/recipe_likes", payload, headers: { 'Authorization': token }
  end

  describe 'sending unauthenticated request' do
    let(:token) { 'invalid token' }
    let(:payload) do
      {
        data: {
          type: 'recipe_likes',
          attributes: {
            recipe_id: 1
          }
        }
      }
    end

    it 'responds with unauthorized' do
      make_request

      expect(response.status).to eq(401)
      expect(response.body).to include('Unauthorized')
    end
  end

  describe 'liking not liked recipe' do
    let!(:recipe1) { create(:recipe) }
    let(:payload) do
      {
        data: {
          type: 'recipe_likes',
          attributes: {
            recipe_id: recipe1.id
          }
        }
      }
    end

    it 'responds with success and created like' do
      expect(RecipeLikeResource).to receive(:build).and_call_original

      expect { make_request }.to change { RecipeLike.where(user: user, recipe: recipe1).size }.by(1)

      expect(response.status).to eq(201)
      expect(d.jsonapi_type).to eq('recipe_likes')
      expect(d.id).to be_present
      expect(d.attributes).to include('created_at', 'updated_at')
      expect(d.relationships).to include('recipe')
    end
  end

  describe 'liking already liked recipe' do
    let!(:recipe1) { create(:recipe) }
    let!(:like) { create(:recipe_like, user: user, recipe: recipe1) }
    let(:payload) do
      {
        data: {
          type: 'recipe_likes',
          attributes: {
            recipe_id: recipe1.id
          }
        }
      }
    end

    it 'responds with unprocessable entity' do
      expect(RecipeLikeResource).to receive(:build).and_call_original

      expect { make_request }.not_to change { RecipeLike.where(user: user, recipe: recipe1).size }

      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['errors'].first).to eq(
        {
          'code' => 'unprocessable_entity',
          'status' => '422',
          'title' => 'Validation Error',
          'detail' => 'User has already liked this recipe',
          'source' => {'pointer'=>'/data/attributes/user_id'},
          'meta' => {
            'attribute' => 'user_id',
            'message' => 'has already liked this recipe',
            'code' => 'taken'
          }
        }
      )
    end
  end
end
