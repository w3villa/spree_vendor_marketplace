class RenameTypeToStoreTypeInStores < ActiveRecord::Migration[5.0]
   def change
      rename_column :stores, :type, :store_type
  end
end
