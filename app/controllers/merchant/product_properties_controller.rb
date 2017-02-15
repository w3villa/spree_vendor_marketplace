class Merchant::ProductPropertiesController < Merchant::ApplicationController

	before_filter :find_product_properties, only: [:edit, :update, :destroy]
	before_filter :load_product

	def index
		@properties = Spree::Property.pluck(:name)
		@product_properties = @product.product_properties
		@product_property = Spree::ProductProperty.new
	end


	private
		def find_product_properties
			@product_property = Spree::ProductProperty.where(id: params[:id])
		end

		def load_product
			@product = Spree::Product.where(slug: params[:product_id]).first
		end

end