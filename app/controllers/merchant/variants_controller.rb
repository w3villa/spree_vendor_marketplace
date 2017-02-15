class Merchant::VariantsController < Merchant::ApplicationController

	layout 'merchant'

	before_filter :find_variant, only: [:edit, :update, :destroy]
	before_filter :load_product

	def index
		@variants = @product.try(:variants)
	end

	def new
		@variant = Spree::Variant.new
	end

	def edit
		
	end

	def create
		@variant = Spree::Variant.new(variant_params)
		@product = Spree::Product.where(id: variant_params["product_id"]).first
		if @variant.save
			redirect_to merchant_stores_products_variants_path(product_id: @product.slug), notice: "Variant Created successfuly"
		else
			render action: 'new'
		end
	end

	def update
		if @variant.update_attributes(variant_params)
			redirect_to :back, notice: "Variant updated successfully"
		else
			render action: 'edit'
		end
	end

	def destroy
		if @variant.destroy
			redirect_to :back, notice: "Successfully deleted"
		else
			redirect_to :back, notice: "Something went wrong"
		end
	end

	private

		def variant_params
			params.require(:variant).permit(:sku, :weight, :height, :width, :depth, :is_master, :product_id, :cost_price, :cost_currency, :position, :track_inventory, :tax_category_id, :price, option_value_ids: [])
		end

		def find_variant
			@variant = Spree::Variant.where(id: params[:id]).first
		end

		def load_product
			@product = Spree::Product.where(slug: params[:product_id]).first
		end

end