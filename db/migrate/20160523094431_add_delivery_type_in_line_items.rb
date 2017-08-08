class AddDeliveryTypeInLineItems < ActiveRecord::Migration[5.0]
  def change
  	add_column :spree_line_items, :delivery_type, :string, default: "home_delivery"
  end
end
