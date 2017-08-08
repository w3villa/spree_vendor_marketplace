class AddLocationDataInStores < ActiveRecord::Migration
  def change
  	add_column :stores, :latitude, :string
  	add_column :stores, :longitude, :string
  end
end
