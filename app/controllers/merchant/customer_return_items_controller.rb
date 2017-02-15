class Merchant::CustomerReturnItemsController < Merchant::ApplicationController

	before_action :find_order
	before_filter :is_active_store

	def index
		@store = current_spree_user.stores.first
    @is_owner = is_owner?(@store)
		@customer_return_items = Spree::CustomerReturnItem.where(order_id: @order.id, store_id: @store.id,status: "refunded")


	end

	def new
		@customer_return_item = Spree::CustomerReturnItem.new
	end

	def create
		p "*************************************"
		p params 
	end

	def destroy
		@customer_return_item = Spree::CustomerReturnItem.find(params[:id])
		if @customer_return_item.delete
			redirect_to :back, :params => @params , notice: "Item Deleted Succssfully"
			return
		else
			redirect_to :back, :params => @params , notice: "Something went wrong"
			return
		end
	end

	def edit
	end

	def eligible_item
		p "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		p params
		@store = current_spree_user.stores.first
    @is_owner = is_owner?(@store)
		if @order.state =='canceled'
			redirect_to spree.orders_path , notice: "Cancel order can not be return"
			return
		elsif (@order.completed_at.to_date + 14.days) < Date.today
			redirect_to spree.orders_path , notice: "Order can only be return within the 14 days of order delivered"
			return
		elsif @order.get_store_delivered_line_items(@store.id).count !=  @order.get_home_delivery_line_item_ids(@store.id).count
			redirect_to spree.orders_path , notice: "You can return item(s) only after complete order is delivered"
			return
		else
			@eligible = @order.get_store_line_items(@store.id).sum(:quantity) - @order.customer_return_items.where(store_id: @store.id,status: "refunded").sum(:return_quantity) == 0 ? false : true
			return
		end
	end

	def return_multiple_item
			p "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			p params
			@store = current_spree_user.stores.first
    	@is_owner = is_owner?(@store)
		if @order.state == 'canceled'
			redirect_to spree.orders_path, notice: "Canceled order can not be return"
			return
		elsif @order.state != "complete"
			redirect_to spree.orders_path, notice: "Order is not complete yet"
			return
		elsif @order.completed_at.to_date + 14.days < Date.today
			redirect_to spree.orders_path, notice: "Order can only be cancel within 14 days of completion"
			return
		else
			if params[:customer_return_items].blank?
				redirect_to :back, :params => @params , notice: "please Select Item to be returned"
				return
			else
				params[:customer_return_items].each do |return_item|
					if return_item["line_item_id"].present? && return_item["quantity"].present?
						if return_item["quantity"].first.blank?
							redirect_to :back, :params => @params , notice: "Quantity can not be blank"
							return
						else
							qty = return_item["quantity"].first.to_i
							line_item = Spree::LineItem.find(return_item["line_item_id"].to_i)
							remaining_qty = Spree::LineItem.find(line_item).quantity - Spree::LineItem.find(line_item).return_quantity(@order)
							p "Lllllllllllllllllllllllllll"
							p remaining_qty
								if qty > remaining_qty  
									redirect_to :back, :params => @params , notice: "Quantity can not be greater than remaining Qty"
									return
								else
									return_item_price = (line_item.price.to_f * qty).round(2)
              		tax_amt = (return_item_price * line_item.tax_rate).round(2) 
									@customer_return_item = Spree::CustomerReturnItem.new(order_id: @order.id, line_item_id: line_item.id, return_quantity: qty,item_return_amount: return_item_price, tax_amount: tax_amt,total: return_item_price + tax_amt,store_id: @store.id,status: "approved")
									unless @customer_return_item.save
										redirect_to merchant_order_customer_return_items_path(@order),  notice: 'Something went wrong'
										return
									end
									# UserMailer.notify_return_order_item(@customer_return_item)
								end
						end
					else
						redirect_to :back, :params => @params , notice: "Please Provide Quantity"
						return
					end
				end
			end
			@amount = Spree::CustomerReturnItem.where(store_id: @store.id,order_id: @order.id,status: "approved").sum(:total).to_f.round(2) * 100
			p "*****************************************"
			p @order
			@paypal_refund_object = @order.payments.valid.last.payment_method.credit(@amount,@order.payments.valid.last.response_code,{})
				p "*****************************************"
				p @paypal_refund_object 
			if @paypal_refund_object.success?
				@paypal_transaction_object = @paypal_refund_object.transaction
				p "*****************************************"
				p @paypal_transaction_object 
				Spree::CustomerReturnItem.where(store_id: @store.id,order_id: @order.id,status: "approved").update_all(transaction_id: @paypal_transaction_object.id,status: "refunded")
				@refund = Spree::Refund.new(payment_id:@order.payments.valid.last.response_code, amount: @paypal_transaction_object.amount * 100, transaction_id: @paypal_transaction_object.id,order_id: @order.id, card_type:@paypal_transaction_object.credit_card_details.card_type, last_card_digits:@paypal_transaction_object.credit_card_details.last_4, expiration:@paypal_transaction_object.credit_card_details.expiration_date, status:@paypal_transaction_object.status)
				if @refund.save
					redirect_to merchant_order_customer_return_items_path(@order),  notice: 'Item(s) Return Successfully'
					return
				else
					redirect_to merchant_order_customer_return_items_path(@order),  notice: 'Something Went Wrong while refunding amount'
					p "*************************************"
					p @refund.errors.full_messages.join(', ')
					return
				end
			else
				p "((((((((((((((((((((((((((((((((((((((((((((((((((((("
				p @paypal_refund_object.errors
				p @paypal_refund_object.errors.first
				Spree::CustomerReturnItem.where(store_id: @store.id,order_id: @order.id,status: "approved").update_all(status: "failed")
				redirect_to merchant_order_customer_return_items_path(@order),  notice: @paypal_refund_object.errors.first.message.to_s
				return
			end
			redirect_to merchant_order_customer_return_items_path(@order),  notice: 'Item(s) Return Succssfully'
			# UserMailer.notify_return_order_items_delivered(params[:customer_return_items]).deliver
		end
	end

	private 

	def find_order
		@order = Spree::Order.find_by_number(params[:order_id])
	end
end
