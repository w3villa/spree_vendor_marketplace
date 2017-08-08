class RenameTableStoreTaxonomyToStoreTaxom < ActiveRecord::Migration[5.0]
  def change
  	rename_table(:store_taxonomies, :store_taxons)
  	rename_column(:store_taxons, :taxonomy_id, :taxon_id)
  end
end
