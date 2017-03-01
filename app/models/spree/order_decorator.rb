module Spree
	Order.class_eval do

    has_many :pickable_line_items, -> {where(spree_line_items: {delivery_type: "pickup"})}, class_name: "Spree::LineItem"
    has_many :stores, through: :products
    has_many :customer_return_items
    has_many :refunds

    attr_accessor :in_wishlist

    self.whitelisted_ransackable_associations = %w[shipments user promotions bill_address ship_address line_items stores]

    # ---------------------------------------- Associations -----------------------------------------------------

    searchable do
      text :number
      time :completed_at
      text :state
      float :total
    end

    after_update :notify_driver, :add_commission

    def store
      stores.first
    end

    #------------------------------- Skip Shipping Step in checkout Flow----------------------------------------
    # checkout_flow do
    #   go_to_state :address
    #   # go_to_state :delivery <== remove this line
    #   go_to_state :payment, :if => lambda { |order| order.payment_required? }
    #   go_to_state :confirm, :if => lambda { |order| order.confirmation_required? }
    #   go_to_state :complete
    #   remove_transition :from => :delivery, :to => :confirm
    # end

    # def ensure_available_shipping_rates
    #   true
    # end

    #------------------------------- Skip Shipping Step in checkout Flow----------------------------------------
    def is_any_item_shipped?
      if line_items.where("delivery_state = ? OR delivery_state = ?",'out_for_delivery','delivered').blank?
        false
      else
        true
      end
    end

    def is_undelivered?
      if line_items.where(delivery_state: 'delivered').nil? && line_items.where(delivery_type: 'home_delivery', delivery_state: 'delivered').count != line_items.where(delivery_type: 'home_delivery').count
        true
      else
        false
      end
    end

    def full_name
      [bill_address.first_name, bill_address.last_name].compact.join(" ")
    end

		def is_home_delivery_product_available?(item_ids)
			line_items.where(id: item_ids).collect(&:delivery_type).include?("home_delivery")
		end

		def ready_to_pick_items(item_ids)
			line_items.where(id: item_ids).collect(&:delivery_state).include?("ready_to_pick")
		end

    def items_state(item_ids)
      line_items.where(id: item_ids).collect(&:delivery_state).uniq.join
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

    def get_order_delivered_line_items
      line_items.where(delivery_state: 'delivered')
    end

    def get_home_delivery_line_item_ids(store_id)
      line_items.joins(:product).where(spree_products: {store_id: store_id}, spree_line_items: {delivery_type: "home_delivery"}).collect(&:id)
    end

    def get_order_home_delivery_line_items_ids
      line_items.where(delivery_type: 'home_delivery')
    end

    def get_store_delivered_line_items(store_id)
      line_items.joins(:product).where(spree_products: {store_id: store_id},spree_line_items: {delivery_state: "delivered"})
    end

    def eligible_for_free_delivery
      item_total.to_f >= 35
    end
    
     def promotion
      adjustments.competing_promos.eligible.reorder("amount ASC, created_at DESC, id DESC").first
    end

    def self_pickup
      !line_items.collect(&:delivery_type).include?("home_delivery")
    end

    def total_after_commission
      commission = Spree::Commission.first.try(:percentage).try(:to_f) || 0
      price = (total.to_f - total.to_f * commission / 100).round(2)
    end


    private

      def notify_driver
        if state == "canceled"
          REDIS_CLIENT.PUBLISH("listUpdate", {order_number: number}.to_json)
        end
      end

      def full_street_address
        [ship_address.address1, ship_address.address2, ship_address.city, ship_address.state, ship_address.country, ship_address.zipcode].compact.join(", ")
      end

      def add_commission
        if self.changes.include?(:state) && self.state == "complete"
          commission = Spree::Commission.try(:first).try(:percentage).try(:to_f) || 0
          p line_items.count
          line_items.each do |line_item|
            line_item_price = (line_item.price.to_f - line_item.price.to_f * commission / 100).round(2)
            user = line_item.product.store.try(:spree_users).try(:first)
            unless user.blank?
              user.update_attributes(amount_due: user.amount_due.to_f + line_item_price.to_f)
            end
          end
        end

      end

	end
end