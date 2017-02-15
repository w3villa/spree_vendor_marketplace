class Merchant::HomeController < Merchant::ApplicationController

	def index
		@stores = current_spree_user.try(:stores)
	end
	
end