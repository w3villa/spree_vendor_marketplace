class AddPaymentModeInStore < ActiveRecord::Migration[5.0]
  def change
  	add_column :stores, :payment_mode, :string
  end
end
