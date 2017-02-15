class Merchant::ProductsController < Merchant::ApplicationController

  # alias_method :old_stock, :stock
  before_filter :is_active_store
  before_filter :verify_access_for_merchants, only: [:new, :index, :stock]
  before_filter :find_product, only: [:edit, :update, :destroy, :images, :product_properties, :stock]

  layout 'merchant'

	def index
    p "______________________________________________________________________________________-"
    p params
    p params.key?("active_tab")
    @tab = params[:active_tab]
    @search = Sunspot.search(Spree::Product) do
      fulltext params[:q][:s] if params[:q] && params[:q][:s]
      with(:visible, true)  if params[:active_tab] == "published" || !params.key?("active_tab")
      with(:visible, false) if params[:active_tab] == "unpublished"
      with(:store_id, current_spree_user.stores.first.try(:id))
      paginate(:page => params[:page], :per_page => 10)
      order_by(:created_at, :desc)
    end
    # @search_1 = Sunspot.search(Spree::Product) do
    #   fulltext params[:q][:s] if params[:q] && params[:q][:s]
    #   with(:visible, false)  
    #   with(:store_id, current_spree_user.stores.first.try(:id))
    #   paginate(:page => params[:page], :per_page => 15)
    #   order_by(:created_at, :desc)
    # end
    @collection =  @search.results
    # @collection_1 =  @search_1.results
    # p @collection
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def new
    @product = Spree::Product.new
    @product.sku = SecureRandom.hex(10).upcase
    @shipping_categories = Spree::ShippingCategory.all
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def edit
    @shipping_categories = Spree::ShippingCategory.all
    @tax_categories = Spree::TaxCategory.all
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def create
    @is_owner = is_owner?(current_spree_user.stores.first)
    @product = Spree::Product.new(product_params)
    @product.attributes = product_params.merge({store_id: current_spree_user.stores.first.id})
    if @product.save
      redirect_to edit_merchant_product_path(@product), notice: "Product added successfully"
    else
      @product.sku = SecureRandom.hex(10).upcase
      @shipping_categories = Spree::ShippingCategory.all
      render action: 'new'
    end
  end

  def bulk_upload
    row_array = Array.new
    my_file = params[:file]
    ImportProductWorker.perform_in(5.seconds, my_file.path, current_spree_user.email)
    redirect_to merchant_products_path, notice: "Your product importing from the csv you uploaded, we will notify you it's progress through email"
  end

  def sample_csv
    send_file(File.open(Rails.root.join("public", "sample_csv.csv"), "r"))
  end

  def update
    redirect_path = params[:redirect_path].present? ? params[:redirect_path] : edit_merchant_product_path(@product)
    if params[:product][:taxon_ids].present?
      params[:product][:taxon_ids] = params[:product][:taxon_ids].split(",")
    end
    if params[:product][:option_type_ids].present?
      params[:product][:option_type_ids] = params[:product][:option_type_ids].split(",")
    end
    if @product.update_attributes(product_params)
      redirect_to redirect_path, notice: "Product updated successfully"
    else
      @shipping_categories = Spree::ShippingCategory.all
      @tax_categories = Spree::TaxCategory.all
      render action: 'edit'
    end
  end

  def destroy
    if @product.destroy
      redirect_to merchant_products_path, notice: "Product deleted successfully"
    else
      redirect_to merchant_products_path, notice: @product.errors.full_messages.join(", ")
    end
  end

  def images
    @image = Spree::Image.new
    @images = Spree::Image.where(viewable_id: @product.id)
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def stock
    @is_owner = is_owner?(current_spree_user.stores.first)
    @stock = Spree::StockItem.new
    @stock_locations = Spree::StockLocation.all
    unless @product.variants.blank?
      @variants = @product.variants
    else
      @variants = [@product.master]
    end
    if !@current_spree_user.has_spree_role?('admin')
      if @product.store_id != @current_spree_user.stores.first.try(:id)
        raise CanCan::AccessDenied.new
      end
    end
    # old_stock
  end

  private

  def product_params
    params.require(:product).permit(:name, :slug, :description, :asin, :brand, :tax_category_id, :price, :sku, :store_id, :shipping_category_id, :available_on, :discontinue_on, :promotionable, :payment_method, :cost_price, :cost_currency, :weight, :height, :width, :depth, :meta_keywords, :meta_description, product_properties_attributes: [:property_id, :value, :id, :property_name], taxon_ids: [], option_type_ids: [])
  end

  def verify_access_for_merchants
    unless @current_spree_user.has_spree_role?('admin') || @current_spree_user.has_spree_role?('merchant')
      raise CanCan::AccessDenied.new
    end
  end

  def find_product
    id = params[:id] || params[:product_id]
    @product = current_spree_user.stores.first.spree_products.where(slug: id).first
    #@product = Spree::Product.where(slug: params[:id]).first || Spree::Product.where(slug: params[:product_id]).first
  end

  protected

    def collection
      return @collection if @collection.present?
      params[:q] ||= {}
      params[:q][:deleted_at_null] ||= "1"

      params[:q][:s] ||= "name asc"
      @collection = super
      # Don't delete params[:q][:deleted_at_null] here because it is used in view to check the
      # checkbox for 'q[deleted_at_null]'. This also messed with pagination when deleted_at_null is checked.
      if params[:q][:deleted_at_null] == '0'
        @collection = @collection.with_deleted
      end
      # @search needs to be defined as this is passed to search_form_for
      # Temporarily remove params[:q][:deleted_at_null] from params[:q] to ransack products.
      # This is to include all products and not just deleted products.
      @search = @collection.ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })
      @collection = @search.result.
            distinct_by_product_ids(params[:q][:s]).
            includes(product_includes).
            page(params[:page]).
            per(params[:per_page] || Spree::Config[:admin_products_per_page])
      @collection
    end

end
