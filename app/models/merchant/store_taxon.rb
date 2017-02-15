module Merchant
	class StoreTaxon < ActiveRecord::Base
		self.table_name = "pyklocal_stores_taxons"
		belongs_to :store, class_name: 'Merchant::Store'
		belongs_to :spree_taxon, foreign_key: :taxon_id, class_name: 'Spree::Taxon'
	end
end
