class RegistrationTypeToUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :registration_type, :string
  end
end
