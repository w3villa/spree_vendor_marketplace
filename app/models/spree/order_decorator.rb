module Spree
	Order.class_eval do
    has_many :stores, through: :products


    self.whitelisted_ransackable_associations = %w[shipments user promotions bill_address ship_address line_items stores]

    # ---------------------------------------- Associations -----------------------------------------------------


    def store
      stores.first
    end
   

    def full_name
      [bill_address.first_name, bill_address.last_name].compact.join(" ")
    end


    def delivery_address
      [ship_address.try(:address1), ship_address.try(:address2), ship_address.try(:city), ship_address.try(:state), ship_address.try(:country)].compact.join(", ")
    end

    def buyer_name
      [ship_address.first_name, ship_address.last_name].compact.join(" ")
    end

    def buyer_zipcode
      ship_address.zipcode
    end

    def get_store_line_items(store_id)
      line_items.joins(:product).where(spree_products: {store_id: store_id})
    end

     def promotion
      adjustments.competing_promos.eligible.reorder("amount ASC, created_at DESC, id DESC").first
    end


    def total_after_commission
      commission = Spree::Commission.first.try(:percentage).try(:to_f) || 0
      price = (total.to_f - total.to_f * commission / 100).round(2)
    end


    private


      def full_street_address
        [ship_address.address1, ship_address.address2, ship_address.city, ship_address.state, ship_address.country, ship_address.zipcode].compact.join(", ")
      end

	end
end