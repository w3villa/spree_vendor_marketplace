class CreateStoreTaxonomies < ActiveRecord::Migration
  def change
    create_table :store_taxonomies do |t|
      t.integer :store_id
      t.integer :taxonomy_id
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
