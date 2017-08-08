class AddDefaultValueForStoreActive < ActiveRecord::Migration[5.0]
  def up
  	change_column :stores, :active, :boolean, default: false
  	add_column :stores, :slug, :string
  end
  def down
  	change_column :stores, :active, :boolean
  	remove_column :stores, :slug
  end
end
