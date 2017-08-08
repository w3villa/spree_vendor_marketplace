class AddDefaultValueForStoreActive < ActiveRecord::Migration
  def up
  	change_column :stores, :active, :boolean, default: false
  	add_column :stores, :slug, :string
  end
  def down
  	change_column :stores, :active, :boolean
  	remove_column :stores, :slug
  end
end
