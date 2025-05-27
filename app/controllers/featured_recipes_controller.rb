# frozen_string_literal: true

class FeaturedRecipesController < ApplicationController
  before_action :authenticate_user!

  def create
    result = Recipes::ToggleFeaturedRecipe.new(recipe_id, current_user.id).call

    if result[:success]
      render jsonapi: recipe_resource
    else
      render json: { errors: [result[:error]] }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Recipe not found'] }, status: :not_found
  end

  private

  def recipe_id
    params.require(:data).require(:attributes).require(:recipe_id)
  end

  def recipe_resource
    RecipeResource.find(data: { type: 'recipes', id: recipe_id })
  end
end
