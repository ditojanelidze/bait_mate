class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :image, null: false
      t.string :description, null: false
      t.text :specie, null: false
      t.text :location, null: false
      t.text :rod, null: false
      t.text :bait, null: false

      t.timestamps
    end
  end
end
