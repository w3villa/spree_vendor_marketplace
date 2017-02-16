class AddEstimatedDeliveryInStores < ActiveRecord::Migration
  def change
    add_column :pyklocal_stores, :estimated_delivery_time, :string, default: "5 - 6 working hours"
  end
end
