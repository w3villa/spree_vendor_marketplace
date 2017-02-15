module Merchant
	class StoreUser < ActiveRecord::Base
		self.table_name = "pyklocal_stores_users"
		belongs_to :store, foreign_key: :store_id, class_name: 'Merchant::Store'
		belongs_to :spree_user, foreign_key: :spree_user_id, class_name: 'Spree::User'
		
		belongs_to :spree_buy_privilege
	  belongs_to :spree_sell_privilege
	end
end
