module Spree
	Product.class_eval do 

		belongs_to :store, class_name: "Merchant::Store"
	end
end