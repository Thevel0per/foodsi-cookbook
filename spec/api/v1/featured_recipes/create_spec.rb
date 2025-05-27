require 'rails_helper'

RSpec.describe "featured_recipes#create", type: :request do
  let(:user) { create(:user) }
  let!(:author) { create(:author, user: user) }
  let(:token) { user.token }

  subject(:make_request) do
    jsonapi_post "/api/v1/featured_recipes", payload, headers: { 'Authorization': token }
  end

  describe 'sending unauthenticated request' do
    let(:token) { 'invalid token' }
    let(:payload) do
      {
        data: {
          type: 'featured_recipes',
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

  describe 'featuring a recipe' do
    let!(:recipe1) { create(:recipe, author: author) }
    let(:payload) do
      {
        data: {
          type: 'featured_recipes',
          attributes: {
            recipe_id: recipe1.id
          }
        }
      }
    end

    it 'responds with updated recipe' do
      expect(RecipeResource).to receive(:find).and_call_original

      expect { make_request }.to change { recipe1.reload.featured }.from(false).to(true)

      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('recipes')
      expect(d.id).to eq(recipe1.id)
      expect(d.attributes).to include('featured' => true)
    end

    context 'when Recipes::ToggleFeaturedRecipe raises ActiveRecord::RecordNotFound' do
      let(:toggle_service_double) { instance_double(Recipes::ToggleFeaturedRecipe) }

      before do
        allow(Recipes::ToggleFeaturedRecipe).to receive(:new).and_return(toggle_service_double)
        allow(toggle_service_double).to receive(:call).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'responds with an error' do
        expect { make_request }.not_to change { recipe1.reload.featured }

        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)['errors'].first).to eq('Recipe not found')
      end
    end

    context 'when Recipes::ToggleFeaturedRecipe result contains error' do
      let(:toggle_service_double) { instance_double(Recipes::ToggleFeaturedRecipe) }

      before do
        allow(Recipes::ToggleFeaturedRecipe).to receive(:new).and_return(toggle_service_double)
        allow(toggle_service_double).to receive(:call).and_return({ success: false, error: 'Some error occurred' })
      end

      it 'responds with an error' do
        expect { make_request }.not_to change { recipe1.reload.featured }

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].first).to eq('Some error occurred')
      end
    end
  end

  describe 'defeaturing recipe' do
    let!(:recipe1) { create(:recipe, author: author, featured: true) }
    let(:payload) do
      {
        data: {
          type: 'featured_recipes',
          attributes: {
            recipe_id: recipe1.id
          }
        }
      }
    end

    it 'responds with updated recipe' do
      expect(RecipeResource).to receive(:find).and_call_original

      expect { make_request }.to change { recipe1.reload.featured }.from(true).to(false)

      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('recipes')
      expect(d.id).to eq(recipe1.id)
      expect(d.attributes).to include('featured' => false)
    end
  end
end
