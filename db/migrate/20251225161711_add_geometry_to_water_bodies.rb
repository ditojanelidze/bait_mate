class AddGeometryToWaterBodies < ActiveRecord::Migration[8.1]
  def change
    add_column :water_bodies, :geometry, :jsonb
    add_column :water_bodies, :geometry_type, :string
  end
end
