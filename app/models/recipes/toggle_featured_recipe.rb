module Recipes
  class ToggleFeaturedRecipe
    FEATURED_LIMIT = 3
    ELIGIBILITY_THRESHOLD_OFFSET = 9


    def initialize(recipe_id, user_id)
      @recipe_id = recipe_id
      @user_id = user_id
    end

    def call
      return { success: false, error: 'User is not an author' } unless author
      return { success: false, error: 'Recipe not eligible for feature' } unless recipe_eligible?
      return { success: false, error: 'Featured limit reached' } if featured_limit_used?

      if toggle_featured
        { success: true, recipe: recipe }
      else
        { success: false, error: 'Failed to toggle featured status' }
      end
    end

    private

    def likes_threshold
      Recipe
        .where(author: author)
        .left_joins(:recipe_likes)
        .offset(ELIGIBILITY_THRESHOLD_OFFSET)
        .select('recipes.id, COUNT(recipe_likes.id) as likes_count')
        .order('COUNT(recipe_likes.id) DESC')
        .limit(1)
        .first
        .likes_count
    end

    def currently_featured_count
      Recipe.where(featured: true).count
    end

    def recipe_eligible?
      likes_threshold <= recipe.likes_count
    end

    def featured_limit_used?
      currently_featured_count >= FEATURED_LIMIT
    end

    def toggle_featured
      if recipe.featured
        recipe.update(featured: false)
      else
        recipe.update(featured: true)
      end
    end

    def author
      @author ||= Author.find_by(user_id: @user_id)
    end

    def recipe
      @recipe ||= Recipe.includes(:recipe_likes).find_by!(id: @recipe_id, author: author)
    end
  end
end
