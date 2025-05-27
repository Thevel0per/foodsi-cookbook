class RecipeLike < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :recipe, presence: true
  validates :user, presence: true
  validates :user_id, uniqueness: { scope: :recipe_id, message: 'has already liked this recipe' }
end
