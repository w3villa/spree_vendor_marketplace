module Spree
	Product.class_eval do 

		# belongs_to :store, class_name: "Merchant::Store"

		# searchable do
  #     text :name 
  #     text :store_name
  #     text :upc_code
  #     text :meta_keywords
  #     text :sku
  #     latlon(:location) { Sunspot::Util::Coordinates.new(store.try(:latitude), store.try(:longitude)) }
  #     text :asin
  #     boolean :visible
      
  #     float :price
  #     float :cost_price
  #     integer :sell_count
  #     integer :view_counter
  #     boolean :buyable

  #     time :created_at

  #     dynamic_string :product_property_ids, :multiple => true do
  #       product_properties.inject(Hash.new { |h, k| h[k] = [] }) do |map, product_property| 
  #         map[product_property.property_id] << product_property.value
  #         map
  #       end
  #     end

  #     string :store_name

  #     integer :store_id

  #     string :brand_name, references: Spree::ProductProperty, multiple: true do
  #       product_properties.where(property_id: properties.where(name: "Brand").first.try(:id)).collect { |p| p.value }.flatten
  #     end

  #     string :taxon_name, references: Spree::Taxon, multiple: true do
  #       taxons.where.not(name: "categories").collect(&:name).flatten
  #     end

  #     integer :taxon_ids, references: Spree::Taxon, multiple: true do
  #       taxons.collect { |t| t.self_and_ancestors.map(&:id) }.flatten
  #     end

  #     string :product_property_name, references: Spree::ProductProperty, multiple: true do
  #       product_properties.collect { |p| p.value }.flatten
  #     end
  #   end

  #   def upc_code
  #     product_properties.where(property_id: properties.find_by_name("UPC").try(:id)).try(:first).try(:value)
  #   end
	end
end