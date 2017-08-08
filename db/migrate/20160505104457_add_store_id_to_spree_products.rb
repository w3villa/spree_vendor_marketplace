class AddStoreIdToSpreeProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_products, :store_id, :integer
  end
end
