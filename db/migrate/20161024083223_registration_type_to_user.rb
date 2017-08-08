class RegistrationTypeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_users, :registration_type, :string
  end
end
