class AddEstimatedDeliveryInStores < ActiveRecord::Migration
  def change
    add_column :stores, :estimated_delivery_time, :string, default: "5 - 6 working hours"
  end
end
