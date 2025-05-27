# frozen_string_literal: true

class RecipeLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    like = RecipeLikeResource.build(create_params)

    if like.save
      render jsonapi: like, status: :created
    else
      render jsonapi_errors: like
    end
  end

  def destroy
    like = RecipeLikeResource.find(params)

    if like.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: like
    end
  end

  private

  def create_params
    create_params = params.permit!.to_h
    create_params["data"]["attributes"].merge!("user_id" => current_user.id)
    create_params
  end
end
