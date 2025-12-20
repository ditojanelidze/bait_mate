class AddVerificationFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :verification_code, :string
    add_column :users, :verification_code_sent_at, :datetime
    add_column :users, :verified, :boolean, default: false, null: false
    add_index :users, :phone_number, unique: true
  end
end
