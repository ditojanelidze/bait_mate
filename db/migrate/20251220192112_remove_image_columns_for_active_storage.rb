class RemoveImageColumnsForActiveStorage < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :image, :string
    remove_column :posts, :image, :string
  end
end
