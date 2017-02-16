class AddStoreIdToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :store_id, :integer
  end
end
