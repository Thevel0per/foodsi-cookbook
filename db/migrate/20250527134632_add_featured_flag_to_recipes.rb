class AddFeaturedFlagToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :featured, :boolean, default: false, null: false
    add_index :recipes, [:author_id, :featured]
  end
end
