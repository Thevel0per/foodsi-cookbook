require 'rails_helper'

RSpec.describe Recipes::ToggleFeaturedRecipe do
  describe '#call' do
    subject(:service) { described_class.new(recipe.id, user.id) }

    context 'when user is not an author' do
      let(:user) { create(:user) }
      let(:recipe) { create(:recipe) }

      it 'returns an error' do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq('User is not an author')
      end
    end

    context 'when recipe is not eligible for feature' do
      let(:user) { create(:user) }
      let(:author) { create(:author, user: user) }
      let!(:most_liked_recipe) { create(:recipe, author: author) }
      let!(:recipe_likes) { create_list(:recipe_like, 2, recipe: most_liked_recipe) }
      let(:recipe) { create(:recipe, author: author) }

      before do
        stub_const(
          "Recipes::ToggleFeaturedRecipe::ELIGIBILITY_THRESHOLD_OFFSET",
          0
        )
      end

      it 'returns an error' do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq('Recipe not eligible for feature')
      end
    end

    context 'when featured limit is reached' do
      let(:user) { create(:user) }
      let(:author) { create(:author, user: user) }
      let!(:featured_recipes) { create_list(:recipe, 3, featured: true, author: author) }
      let(:recipe) { create(:recipe, author: author) }

      it 'returns an error' do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq('Featured limit reached')
      end
    end

    context 'when recipe was not featured before' do
      let(:user) { create(:user) }
      let(:author) { create(:author, user: user) }
      let(:recipe) { create(:recipe, author: author) }

      it 'toggles the recipe to featured' do
        result = service.call
        expect(result[:success]).to be_truthy
        expect(recipe.reload.featured).to be_truthy
      end
    end

    context 'when recipe was already featured' do
      let(:user) { create(:user) }
      let(:author) { create(:author, user: user) }
      let(:recipe) { create(:recipe, author: author, featured: true) }

      it 'toggles the recipe to not featured' do
        result = service.call
        expect(result[:success]).to be_truthy
        expect(recipe.reload.featured).to be_falsey
      end
    end

    context 'when recipe update fails' do
      let(:user) { create(:user) }
      let(:author) { create(:author, user: user) }
      let(:recipe) { create(:recipe, author: author) }

      before do
        allow_any_instance_of(Recipe).to receive(:update).and_return(false)
      end

      it 'returns an error' do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq('Failed to toggle featured status')
      end
    end
  end
end
