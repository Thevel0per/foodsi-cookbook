# frozen_string_literal: true

class RecipeLikeResource < ApplicationResource
  attribute :user_id, :integer, writeable: true, readable: false
  attribute :recipe_id, :integer, writeable: true, readable: false
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  belongs_to :recipe
end
