class RecipeResource < ApplicationResource
  attribute :title, :string
  attribute :text, :string
  attribute :difficulty, :string
  attribute :preparation_time, :integer
  attribute :created_at, :datetime
  attribute :likes_count, :integer, filterable: false
  attribute :featured, :boolean

  secondary_endpoint '/featured_recipes', [:create]


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
  filter :author_id, :integer

  stat :by_category do
    count do |scope|
      scope.joins(:categories)
           .group('categories.name')
           .count
    end
  end

  stat :by_month_week do
    count do |scope|
      scope.group(
        "strftime('%Y-%m', created_at) || '-W' || " \
          "((strftime('%d', created_at) - 1) / 7 + 1)"
      ).count
    end
  end

  stat :likes_by_category do
    count do |scope|
      scope.joins(:categories)
           .left_joins(:recipe_likes)
           .group(Arel.sql('categories.name'))
           .count('recipe_likes.id')
    end
  end

  stat :likes_by_month_week do
    count do |scope|
      scope
      .left_joins(:recipe_likes)
      .group(
        "strftime('%Y-%m', recipes.created_at) || '-W' || " \
          "((strftime('%d', recipes.created_at) - 1) / 7 + 1)"
      ).count('recipe_likes.id')
    end
  end
end
