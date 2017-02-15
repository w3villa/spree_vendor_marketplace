class Merchant::ReturnAuthorizationReasonsController < Merchant::ApplicationController

  def index
    @return_auth_reason = Spree::ReturnAuthorizationReason.where(store_id: current_spree_user.stores.first.id).order("created_at desc")
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def new
    @is_owner = is_owner?(current_spree_user.stores.first)
    @new_reason = Spree::ReturnAuthorizationReason.new
  end

  def edit
    @is_owner = is_owner?(current_spree_user.stores.first)
    @new_reason = Spree::ReturnAuthorizationReason.where(params[:id]).first
  end

  def create
    @is_owner = is_owner?(current_spree_user.stores.first)
    @new_reason = Spree::ReturnAuthorizationReason.new(return_reason_param.merge({store_id: current_spree_user.stores.first.id}))
    if @new_reason.save
      redirect_to merchant_return_authorization_reasons_path, notice: ""
    else
      render action: 'index', notice: "Reason Is allready Created"
    end
  end

  def update
    @new_reason = Spree::ReturnAuthorizationReason.where(params[:id]).first
    if @new_reason.update_attributes(return_reason_param)
      redirect_to merchant_return_authorization_reasons_path, notice: "Reason update successfully"
    else
      redirect_to merchant_return_authorization_reasons_path, notice: "Something went wrong"
    end
  end

  def destroy
    @new_reason = Spree::ReturnAuthorizationReason.where(params[:id]).first
    if @new_reason.destroy
      redirect_to merchant_return_authorization_reasons_path, notice: "Reason deleted successfully"
    else
      redirect_to merchant_return_authorization_reasons_path, notice: "Something went wrong"
    end
  end

  private

    def return_reason_param
      params.require(:return_authorization_reason).permit(:name, :active)
      
    end

end