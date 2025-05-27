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

  describe 'fetch recipes filtered by author id' do
    let!(:author) { create(:author) }
    let!(:recipe1) { create(:recipe, author: author) }
    let!(:recipe2) { create(:recipe) }
    let!(:recipe3) { create(:recipe, author: author) }

    before do
      params[:filter] = { author_id: { eq: author.id } }
    end

    it 'returns recipes by the specified author' do
      expect(RecipeResource).to receive(:all).and_call_original

      make_request

      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['recipes'])
      expect(d.map(&:id)).to match_array([recipe1.id, recipe3.id])
    end
  end

  describe 'fetch recipes with stats for categories' do
    let!(:category1) { create(:category, name: 'Dessert') }
    let!(:category2) { create(:category, name: 'Main Course') }
    let!(:recipe1) { create(:recipe, categories: [category1]) }
    let!(:recipe2) { create(:recipe, categories: [category2]) }
    let!(:recipe_likes1) { create_list(:recipe_like, 2, recipe: recipe1) }
    let!(:recipe_like2) { create(:recipe_like, recipe: recipe2) }

    before do
      params[:stats] = { by_category: 'count', likes_by_category: 'count' }
    end

    it 'returns stats grouped by category' do
      expect(RecipeResource).to receive(:all).and_call_original

      make_request

      expect(response.status).to eq(200), response.body
      expect(jsonapi_meta['stats']).to include(
        'by_category' => {
          'count' => {
            'Dessert' => 1,
            'Main Course' => 1
          }
        },
        'likes_by_category' => {
          'count' => {
            'Dessert' => 2,
            'Main Course' => 1
          }
        }
      )
    end
  end

  describe 'fetch recipes with stats for months/weeks' do
    let!(:recipe1) { create(:recipe, created_at: DateTime.parse('01.05.2025')) }
    let!(:recipe2) { create(:recipe, created_at: DateTime.parse('06.05.2025')) }
    let!(:recipe3) { create(:recipe, created_at: DateTime.parse('07.05.2025')) }
    let!(:recipe4) { create(:recipe, created_at: DateTime.parse('08.05.2025')) }
    let!(:recipe_likes1) { create_list(:recipe_like, 2, recipe: recipe1) }
    let!(:recipe_like2) { create(:recipe_like, recipe: recipe2) }
    let!(:recipe_like3) { create(:recipe_like, recipe: recipe3) }
    let!(:recipe_like4) { create(:recipe_like, recipe: recipe4) }

    before do
      params[:stats] = { by_month_week: 'count', likes_by_month_week: 'count' }
    end

    it 'returns stats grouped by category' do
      expect(RecipeResource).to receive(:all).and_call_original

      make_request

      expect(response.status).to eq(200), response.body
      expect(jsonapi_meta['stats']).to include(
         'by_month_week' => {
           'count' => {
             '2025-05-W1'=> 3,
             '2025-05-W2' => 1
           }
         },
         'likes_by_month_week' => {
           'count' => {
             '2025-05-W1'=> 4,
             '2025-05-W2' => 1
           }
         }
       )
    end
  end
end
