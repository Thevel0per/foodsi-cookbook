class Recipe < ApplicationRecord
  validates :title, presence: true, length: { maximum: 100, minimum: 3 }
  validates :text, presence: true, length: { maximum: 1000, minimum: 10 }
  validates :preparation_time, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :featured, inclusion: { in: [true, false] }

  enum difficulty: { easy: 0, medium: 1, hard: 2, expert: 3 }

  belongs_to :author
  has_many :recipe_categories, dependent: :destroy
  has_many :categories, through: :recipe_categories
  has_many :recipe_likes, dependent: :destroy

  def likes_count
    recipe_likes.size
  end
end
