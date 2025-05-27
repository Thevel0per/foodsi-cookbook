require 'rails_helper'

RSpec.describe "recipes#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/api/v1/recipes", params: params
  end

  describe 'basic fetch' do
    let!(:recipe1) { create(:recipe) }
    let!(:recipe2) { create(:recipe) }

    it 'works' do
      expect(RecipeResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['recipes'])
      expect(d.map(&:id)).to match_array([recipe1.id, recipe2.id])
    end
  end

  describe 'fetch recipes with likes_counts' do
    let!(:recipe1) { create(:recipe) }
    let!(:recipe2) { create(:recipe) }
    let!(:like1) { create(:recipe_like, recipe: recipe1) }
    let!(:like2) { create(:recipe_like, recipe: recipe1) }
    let!(:like3) { create(:recipe_like, recipe: recipe2) }

    before do
      params[:fields] = { recipes: 'likes_count' }
    end

    it 'returns recipes with likes_count' do
      expect(RecipeResource).to receive(:all).and_call_original

      make_request

      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['recipes'])
      expect(d.map(&:id)).to match_array([recipe1.id, recipe2.id])
      expect(d.map(&:attributes).map { |a| a['likes_count'] }).to eq([2, 1])
    end
  end

  describe 'fetch only recipes liked by user' do
    let(:user) { create(:user) }
    let!(:recipe1) { create(:recipe) }
    let!(:recipe2) { create(:recipe) }
    let!(:recipe3) { create(:recipe) }
    let!(:like1) { create(:recipe_like, user: user, recipe: recipe1) }
    let!(:like2) { create(:recipe_like, user: user, recipe: recipe2) }

    before do
      params[:filter] = { liked_by_user_id: { eq: user.id } }
    end

    it 'returns only recipes liked by the user' do
      expect(RecipeResource).to receive(:all).and_call_original

      make_request

      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['recipes'])
      expect(d.map(&:id)).to match_array([recipe1.id, recipe2.id])
    end
  end
end
