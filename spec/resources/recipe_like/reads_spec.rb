require 'rails_helper'

RSpec.describe RecipeLikeResource, type: :resource do
  describe 'serialization' do
    let!(:recipe_like) { create(:recipe_like) }

    it 'serializes correct data' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(recipe_like.id)
      expect(data.jsonapi_type).to eq('recipe_likes')
      expect(data.attributes).to include(
        'created_at' => recipe_like.created_at.strftime('%Y-%m-%dT%H:%M:%S+00:00'),
        'updated_at' => recipe_like.updated_at.strftime('%Y-%m-%dT%H:%M:%S+00:00')
      )
      expect(data.attributes).to_not include('user_id', 'recipe_id')
      expect(data.relationships).to include('recipe' => {
        'links' => { 'related' => "/api/v1/recipes/#{recipe_like.recipe_id}" }
      })
    end
  end
end
