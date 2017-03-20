class Merchant::StoresController < Merchant::ApplicationController

	before_filter :authenticate_user!, except: [:show, :new, :create, :index]
  before_action :set_store, only: [:show, :edit, :update, :destroy]

	def index
    if current_spree_user.present?
  		@stores = current_spree_user.try(:stores)
      if @stores.present?
        redirect_to @stores.first
      else
        redirect_to new_merchant_store_path
      end  
    else
      redirect_to spree.root_path, notice: "you are not logged in"
    end   
	end

	def show

    if params[:q].present? && params[:q][:search].present?
      @products =  Spree::Product.where("name LIKE ? AND store_id = ?","%#{params[:q][:search]}%",current_spree_user.stores.first.id).order("created_at desc").page(params[:page]).per(15)
    else
      @products =  Spree::Product.where(store_id: @store.id).order("created_at desc").page(params[:page]).per(15)
    end
    @is_owner = is_owner?(@store)
  end

  # GET /stores/new
  def new
    begin
      if current_spree_user.present?
        if current_spree_user.stores.present?
          redirect_to current_spree_user.stores.first
        else
          @store = Merchant::Store.new()
          @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
        end
      else
        redirect_to spree.root_path, notice: "you are not logged in"
      end
    rescue Exception => e
      p e.message
      
    end
  end

  # GET /stores/1/edit
  def edit
    if @store.id != current_spree_user.stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
      raise CanCan::AccessDenied.new
    end
    # @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
    @taxons = Spree::Taxon.where(parent_id: nil)
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Merchant::Store.new(store_params)
    @store.attributes = {store_users_attributes: [spree_user_id: current_spree_user.id], active: true}
    respond_to do |format|
      if @store.save
        format.html { redirect_to merchant_store_url(id: @store.slug, anchor: "map"), notice: 'Store approval is pending' }
        format.json { render action: 'show', status: :created, location: @store }
      else
        @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
        format.html { render action: 'new' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
    # @user = Spree::User.new(user_params)
    # if @user.save
    #   @store = Merchant::Store.new(store_params)
    #   @store.attributes = {store_users_attributes: [spree_user_id: @user.id], active: true}
    #   respond_to do |format|
    #     if @store.save
    #       format.html { redirect_to merchant_store_url(id: @store.slug, anchor: "map"), notice: 'Store approval is pending' }
    #       format.json { render action: 'show', status: :created, location: @store }
    #     else
    #       #@taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
    #       @taxons = Spree::Taxon.where(parent_id: nil).first.id
    #       format.html { render action: 'new' }
    #       format.json { render json: @store.errors, status: :unprocessable_entity }
    #       flash[:error] = @store.errors.full_messages.join(", ")
    #     end
    #   end
    # else
    #   respond_to do |format|
    #     format.html { render action: 'new' }
    #   end
    # end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    if @store.id != current_spree_user.stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
      raise CanCan::AccessDenied.new
    end
    if @store.update_attributes(store_params)
      flash[:notice] = "Store updated successfully"
      redirect_to @store
    else
      flash[:error] = "Error occurred while updating store"
      render action: 'edit' 
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    if @store.id != current_spree_user.stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
      raise CanCan::AccessDenied.new
    end
    @store.destroy
    respond_to do |format|
      if current_spree_user.has_spree_role?('admin')
        format.html { redirect_to merchant_stores_url, notice: 'Store was deleted successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to merchant_stores_url, notice: 'Store was deleted successfully.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Merchant::Store.where(slug: params[:id]).first
      redirect_to spree.root_url, notice: "Store not available" unless @store.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_params
      params.require(:merchant_store).permit(:name, :estimated_delivery_time, :active, :certificate, :payment_mode, :description, :manager_first_name, :manager_last_name, :phone_number, :store_type, :street_number, :city, :state, :zipcode, :country, :site_url, :terms_and_condition, :payment_information, :logo, spree_taxon_ids: [], store_users_attributes: [:spree_user_id, :store_id, :id])
    end

    def user_params
      params.require(:merchant_store).permit(:email,:password)
    end

end