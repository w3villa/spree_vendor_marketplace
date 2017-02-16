class RenameTableStoreTaxonomyToStoreTaxom < ActiveRecord::Migration
  def change
  	rename_table(:store_taxonomies, :store_taxons)
  	rename_column(:store_taxons, :taxonomy_id, :taxon_id)
  end
end
