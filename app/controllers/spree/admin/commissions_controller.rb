module Spree
	module Admin
		class CommissionsController < Spree::Admin::ResourceController

		  def index
		    @commission = Spree::Commission.first
		    if @commission.blank?
		      @commission = Spree::Commission.new
		    end
		  end

		end
	end
end