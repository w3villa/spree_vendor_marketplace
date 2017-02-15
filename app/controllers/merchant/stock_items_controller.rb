class Merchant::StockItemsController < Merchant::ApplicationController

	layout 'merchant'
	before_filter :find_stock_item, only: [:edit, :update, :destroy]

	def new
		@stock = Spree::StockItem.new
		@product = Spree::Product.where(slug: params[:product_id]).first
	end

	def edit
		@product = Spree::Product.where(slug: params[:product_id]).first
	end

	def create
		@stock = Spree::StockItem.new(stock_item_params)
		if @stock.save
			redirect_to :back, notice: "Succefully updated"
		else
			redirect_to :back, notice: @stock.errors.full_messages.join(", ")
		end
	end

	def update
		if @stock.update_attributes(stock_item_params)
			redirect_to :back, notice: "Succefully updated"
		else
			redirect_to :back, notice: @stock.errors.full_messages.join(", ")
		end
	end

	def destroy
		if @stock.destroy
			redirect_to :back, notice: "Succefully deleted"
		else
			redirect_to :back, notice: "Something went wrong"
		end
	end

	private

		def stock_item_params
			params.require(:stock_item).permit(:stock_location_id, :variant_id, :count_on_hand, :backorderable)
		end

		def find_stock_item
			@stock = Spree::StockItem.find(params[:id])
		end

end