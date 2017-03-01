module Spree
	class Admin::SellersController < Admin::ResourceController

    before_filter :find_seller, only: [:edit, :update, :delete, :stores, :store_orders, :delete_store]

		def index
			respond_with(@collection) do |format|
        format.html
        format.json { render :json => json_data }
      end
		end

    def edit
      @role = Spree::Role.where(name: "merchant").first
    end

    def update
      if params[:seller][:password].blank? && params[:seller][:password_confirmation].blank?
        params[:seller].delete(:password)
        params[:seller].delete(:password_confirmation)
      end

      if @seller.update_attributes(seller_params)
        flash.now[:success] = Spree.t(:account_updated)
      end

      render :edit
    end

    def stores
      @store = @seller.stores.first
      @products = @store.spree_products if @store.present?
    end

    def delete_store
      @store = @seller.stores.first
      if @store.destroy
        redirect_to admin_seller_stores_path(@seller), notice: "Store deleted successfully"
      else
        redirect_to admin_seller_stores_path(@seller), notice: "Something went wrong"
      end
    end

    def store_orders
      @store_order = @seller.stores.first.store_orders if @seller.stores.present?
    end

		protected

			def collection
        return @collection if @collection.present?
        @collection = Spree::Role.find_by_name("merchant").try(:users)
        if request.xhr? && params[:q].present?
          @collection = @collection
                            .where("spree_users.email #{LIKE} :search
                            			 OR (spree_users.first_name #{LIKE} :search)
                            			 OR (spree_users.last_name #{LIKE} :search)",
                                  { :search => "#{params[:q].strip}%" })
                            .limit(params[:limit] || 100)
        else
          @search = @collection.ransack(params[:q])
          @collection = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
        end
      end

      def find_seller
        id = params[:id] || params[:seller_id]
        @seller = Spree::User.find_by_id(id)
      end

      def seller_params
        params.require(:seller).permit(:email, :first_name, :last_name, :password, :password_confirmation)
      end

	end
end