class RenameTables < ActiveRecord::Migration
  def up
  	rename_table :stores, :pyklocal_stores
  	rename_table :store_spree_users, :pyklocal_stores_users
  	rename_table :store_taxons, :pyklocal_stores_taxons
  end
  def down
  	rename_table :pyklocal_stores, :stores
  	rename_table :pyklocal_stores_users, :store_spree_users
  	rename_table :pyklocal_stores_taxons, :store_taxons
  end
end
