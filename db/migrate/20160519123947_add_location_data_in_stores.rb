class AddLocationDataInStores < ActiveRecord::Migration
  def change
  	add_column :pyklocal_stores, :latitude, :string
  	add_column :pyklocal_stores, :longitude, :string
  end
end
