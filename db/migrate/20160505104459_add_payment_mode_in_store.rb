class AddPaymentModeInStore < ActiveRecord::Migration
  def change
  	add_column :stores, :payment_mode, :string
  end
end
