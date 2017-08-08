class AddEstimatedDeliveryInStores < ActiveRecord::Migration[5.0]
  def change
    add_column :stores, :estimated_delivery_time, :string, default: "5 - 6 working hours"
  end
end
