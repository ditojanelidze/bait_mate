class CreateWaterBodies < ActiveRecord::Migration[8.1]
  def change
    create_table :water_bodies do |t|
      t.string :name, null: false
      t.string :name_en
      t.string :water_type, null: false
      t.bigint :osm_id, null: false
      t.decimal :latitude, precision: 10, scale: 7, null: false
      t.decimal :longitude, precision: 10, scale: 7, null: false
      t.text :description
      t.decimal :area

      t.timestamps
    end

    add_index :water_bodies, :osm_id, unique: true
    add_index :water_bodies, :water_type
    add_index :water_bodies, [:latitude, :longitude]
  end
end
