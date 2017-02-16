class RenameTypeToStoreTypeInStores < ActiveRecord::Migration
   def change
      rename_column :stores, :type, :store_type
  end
end
