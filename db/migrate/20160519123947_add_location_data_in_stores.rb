class AddLocationDataInStores < ActiveRecord::Migration[5.0]
  def change
  	add_column :stores, :latitude, :string
  	add_column :stores, :longitude, :string
  end
end
