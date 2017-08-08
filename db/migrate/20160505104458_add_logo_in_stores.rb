class AddLogoInStores < ActiveRecord::Migration[5.0]
  def change
  	add_attachment :stores, :logo
  end
end
