module Spree
	class Seller < ActiveRecord::Base

		self.table_name = "spree_users"
		has_many :payment_histories, foreign_key: :user_id, class_name: "Spree::PaymentHistory"
		has_many :store_spree_users, foreign_key: :spree_user_id, class_name: 'Merchant::StoreUser'
  	has_many :stores, through: :store_spree_users, class_name: 'Merchant::Store'

		before_destroy :notify_store_destroy, :destroy_store

		def full_name
	    (first_name || last_name) || (email)
	  end

	  def destroy_store
	    stores.first.destroy
 		end

   def notify_store_destroy
      #if self.has_store
        # UserMailer.notify_user_store_destroy(self).deliver_now
      #end
    end
		
	end
end