if Spree.user_class
	Spree.user_class.class_eval do

		has_many :store_users, foreign_key: :spree_user_id, class_name: 'Merchant::StoreUser'
	  has_many :stores, through: :store_users, class_name: 'Merchant::Store'
	end
end