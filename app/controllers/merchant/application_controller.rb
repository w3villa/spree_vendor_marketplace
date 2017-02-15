class Merchant::ApplicationController < ActionController::Base
  
	before_filter :authenticate_user!

  protect_from_forgery with: :exception
	
	include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Store
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::RespondWith
  include Spree::Core::ControllerHelpers::Search
  include Spree::Core::ControllerHelpers::StrongParameters
  helper Spree::BaseHelper
  helper Spree::OrdersHelper
  helper Spree::ProductsHelper
  helper Spree::StoreHelper
  helper Spree::TaxonsHelper

  before_filter :load_initials

  layout 'merchant'

  def load_initials
    @categories = Spree::Taxon.includes(children: {children: :children}).where(name: "Category").first.try(:children)
    @price_index_bitcoin = price_index_bitcoin
  end

  def price_index_bitcoin
    if ["staging", "production"].include?(Rails.env)
      JSON.parse(open('https://coinbase.com/api/v1/prices/spot_rate').read)["amount"].to_f
    else
      623.5
    end
  end

  def is_active_store
    if current_spree_user && (current_spree_user.stores && !current_spree_user.stores.first.active)
      redirect_to merchant_pyklocal_store_path(id: current_spree_user.stores.first.id), notice: "Your store approval is pending"
    end
  end

  def is_owner?(store)
    if current_spree_user
      current_spree_user.stores.include?(store)
    else
      false
    end
  end

  def try_spree_current_user
    current_spree_user
  end

  def current_currency
    
  end

  def authenticate_user!
    unless current_spree_user && current_spree_user.has_spree_role?("merchant")
      redirect_to spree.login_path, notice: "You are not authorized to access this page."
    end
  end

end