class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.text :description
      t.string :manager_first_name
      t.string :manager_last_name
      t.string :phone_number
      t.string :type
      t.string :street_number
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.string :site_url
      t.boolean :terms_and_condition
      t.text :payment_information
      t.boolean :active

      t.timestamps
    end
  end
end
