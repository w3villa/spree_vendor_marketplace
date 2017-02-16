class CreateStoreSpreeUsers < ActiveRecord::Migration
  def change
    create_table :store_spree_users do |t|
      t.integer :spree_user_id
      t.integer :store_id
      t.string :role

      t.timestamps
    end
  end
end
