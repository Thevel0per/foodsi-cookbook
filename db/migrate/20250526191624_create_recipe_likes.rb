class CreateRecipeLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipe_likes do |t|
      t.references :recipe, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.timestamps
    end
  end
end
