class RecipeResource < ApplicationResource
  attribute :title, :string
  attribute :text, :string
  attribute :difficulty, :string
  attribute :preparation_time, :integer
  attribute :created_at, :datetime
  attribute :likes_count, :integer, filterable: false

  def base_scope
    Recipe.includes(:recipe_likes)
  end

  belongs_to :author
  many_to_many :categories

  filter :liked_by_user_id, :integer do
    eq do |scope, value|
      scope.liked_by_user_id(value)
    end
  end
end
