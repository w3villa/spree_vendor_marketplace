class Merchant::OrdersController < Merchant::ApplicationController

	before_filter :is_active_store
  before_filter :find_order, only: [:edit, :update, :validate_actions, :customer, :adjustments, :payments, :returns, :approve, :cancel, :return_item_accept, :return_item_reject]

	def index
    @store = current_spree_user.stores.first
    if @store.present?
      params[:q] = {} unless params[:q]
      if params[:q][:orders_completed_at_gt].blank?
        params[:q][:orders_completed_at_gt] = Time.zone.now.beginning_of_month
      else
        params[:q][:orders_completed_at_gt] = Time.zone.parse(params[:q][:orders_completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
      end

      if params[:q] && !params[:q][:orders_completed_at_lt].blank?
        params[:q][:orders_completed_at_lt] = Time.zone.parse(params[:q][:orders_completed_at_lt]).end_of_day rescue ""
      end

      params[:q][:s] ||= "completed_at desc"

      if params[:q][:search].present?
        @search = @store.orders.complete.where("number LIKE ?", "%#{params[:q][:search]}%").uniq.ransack(params[:q])
      else
        @search = @store.orders.complete.uniq.ransack(params[:q])
      end

      @orders = Kaminari.paginate_array(@search.result).page(params[:page]).per(10)
      @is_owner = is_owner?(@store)
    else
      @orders = nil
    end
  end

  def new
  	if !@current_spree_user.has_spree_role?('admin')
      if @current_spree_user.has_spree_role?('merchant')
        raise CanCan::AccessDenied.new
      end
    end  
    @order = Order.create
    @order.created_by = try_spree_current_user
    @order.save
    redirect_to edit_admin_order_url(@order)
  end

  def edit
  	validate_actions
    unless @order.complete?
      @order.refresh_shipment_rates
    end
    @store = current_spree_user.stores.first
  end

  def update
  	validate_actions
    if @order.update_attributes(params[:order]) && @order.line_items.present?
      @order.update!
      unless @order.complete?
        # Jump to next step if order is not complete.
        redirect_to admin_order_customer_path(@order) and return
      end
    else
      @order.errors.add(:line_items, Spree.t('errors.messages.blank')) if @order.line_items.empty?
    end

    render :action => :edit
  end

  def cancel
  	validate_actions
    @order.cancel!
    flash[:success] = Spree.t(:order_canceled)
    redirect_to :back
  end

  def customer
    @customer = @order.user
    @bill_address = @order.try(:bill_address)
  end

  def adjustments
    @adjustments = @order.adjustments
  end

  def payments
    @payments = @order.payments
  end

  def returns
    p "((((((((((((((((((((((((((("
    p current_spree_user.stores.first
    @store = current_spree_user.stores.first
    @is_owner = is_owner?(@store)
    @return_orders = @store.customer_return_items.where(status: "refunded").collect(&:order_id).uniq
  end

  def approve
    # if @order.update_attributes(approver_id: current_spree_user.id, approved_at: Time.zone.now, considered_risky: false)
    #   redirect_to :back, notice: "Order Approved"
    # else
    #   redirect_to :back, notice: @order.errors.full_messages.join(", ")
    # end
    p "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    p params
    @store = current_spree_user.stores.first
    @is_owner = is_owner?(@store)
    @customer_return_items = []
    @order.customer_return_items.where(status: 'Requested').each do |item|
      if item.line_item.variant.product.store_id == @store.id
        @customer_return_items << item
      end
    end
    p @customer_return_items
  end


  def return_item_accept_reject
    @store = current_spree_user.stores.first
    @is_owner = is_owner?(@store)
     p "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
     p params
    # p params[:commit]
    # p params[:customer_return_items].first["id"]
    # if params[:customer_return_items].present?
    #   if params[:commit] == "Accept"
    #     params[:customer_return_items].each do |return_item|
    #       unless Spree::CustomerReturnItem.find(return_item["id"].to_i).update_attributes(status: 'Accepted')
    #         redirect_to :back ,notice: "Unable to update the status of item"
    #       end
    #     end
    #    # params[:customer]
    #     p "666666666666"
    #   elsif params[:commit] == "Reject"
    #     params[:customer_return_items].each do |return_item|
    #       unless Spree::CustomerReturnItem.find(return_item["id"].to_i).update_attributes(status: 'Rejected')
    #         redirect_to :back ,notice: "Unable to update the status of item"
    #       end
    #     end
    #     p "0000000000"
    #   else
    #     redirect_to :back ,notice: "Wrong Choice of Action"
    #   end
    # else
    #   redirect_to :back, notice: "No item is selected for Approval or Rejection"
    #   return
    # end

    if params[:customer_return_items].blank?
        redirect_to :back, :params => @params , notice: "please Select Item to be returned"
        return
    else
      params[:customer_return_items].each do |approve_item|
         id = approve_item["id"].to_i
         @customer_return_item = Spree::CustomerReturnItem.find(id)
        if @customer_return_item.status == 'Requested'
          if approve_item["id"].present? && approve_item["quantity"].present?
            if approve_item["quantity"].first.blank?
              redirect_to :back, :params => @params , notice: "Quantity can not be blank"
              return
            else
              qty = approve_item["quantity"].first.to_i
              tax_rate = @customer_return_item.line_item.variant.tax_category_id.present? ? @customer_return_item.line_item.variant.tax_category.tax_rates.first.amount.to_f : @customer_return_item.line_item.product.tax_category.tax_rates.first.amount.to_f 
              p "**********************************************************"
              p qty
              p id
              p tax_rate
               return_item_price = (@customer_return_item.line_item.price.to_f * qty).round(2)
              tax_amt = (return_item_price * tax_rate).round(2) 

              if qty == 0
                merchant_status = "Rejected"
                refund_status = "NA"
              elsif qty == @customer_return_item.return_quantity
                merchant_status = "Full Return"
                refund_status = "Full Refund"
              else
                merchant_status = "Partial Return"
                refund_status = "Partial Refund"
              end
              p merchant_status
              p refund_status
              if  @customer_return_item.update_attributes(item_return_amount: return_item_price, tax_amount: tax_amt, total: return_item_price + tax_amt, status: merchant_status, refunded: refund_status, approve_qty: qty)
                # redirect_to :back, :params => @params , notice: "Approve Succesfully"
                # return
              else
                redirect_to :back, :params => @params , notice: "Error Occured While approving the items(s)"
                return
              end
              # @customer_return_item = Spree::CustomerReturnItem.find()
            end
          else
            redirect_to :back, :params => @params , notice: "Please Provide Quantity"
            return
          end
        else
          redirect_to :back, :params => @params , notice: "Item is Already Updated"
          return
        end
      end
    end

    redirect_to :back, :params => @params , notice: "Approved Succesfully"
  end

  def cancel
    validate_actions
    @order.cancel!
    flash[:success] = Spree.t(:order_canceled)
    redirect_to :back
  end

  private 

  	def validate_actions
  		rais_error = true
    	if !@current_spree_user.has_spree_role?('admin')
        if @current_spree_user.has_spree_role?('merchant')
        		@order.line_items.each do |line_item|
        			if line_item.variant.product.store_id == @current_spree_user.stores.first.id
        				rais_error = false
        				break
        			end	
        		end
        	if rais_error
          	raise CanCan::AccessDenied.new
          end	
        end
      end  
  	end

    def find_order
      @order = Spree::Order.where(number: params[:id]).first || Spree::Order.where(number: params[:order_id]).first
    end	

end