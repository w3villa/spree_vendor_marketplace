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

  # def new
  # 	if !@current_spree_user.has_spree_role?('admin')
  #     if @current_spree_user.has_spree_role?('merchant')
  #       raise CanCan::AccessDenied.new
  #     end
  #   end  
  #   @order = Order.create
  #   @order.created_by = try_spree_current_user
  #   @order.save
  #   redirect_to edit_admin_order_url(@order)
  # end

  # def edit
  # 	validate_actions
  #   unless @order.complete?
  #     @order.refresh_shipment_rates
  #   end
  #   @store = current_spree_user.stores.first
  # end

  # def update
  # 	validate_actions
  #   if @order.update_attributes(params[:order]) && @order.line_items.present?
  #     @order.update!
  #     unless @order.complete?
  #       # Jump to next step if order is not complete.
  #       redirect_to admin_order_customer_path(@order) and return
  #     end
  #   else
  #     @order.errors.add(:line_items, Spree.t('errors.messages.blank')) if @order.line_items.empty?
  #   end

  #   render :action => :edit
  # end


  # def customer
  #   @customer = @order.user
  #   @bill_address = @order.try(:bill_address)
  # end

  # def adjustments
  #   @adjustments = @order.adjustments
  # end

  # def payments
  #   @payments = @order.payments
  # end

  
  private 


    def find_order
      @order = Spree::Order.where(number: params[:id]).first || Spree::Order.where(number: params[:order_id]).first
    end	

end