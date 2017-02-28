class SpreeVendorMarketplaceAbility

	include CanCan::Ability

  def initialize(user)
    
    user ||= Spree.user_class.new

    if user.has_spree_role?('merchant') || user.has_spree_role?('user')
    	#can [:admin, :create, :index], Product 
    	#can [:manage], Product, store_id: user.stores.first.try(:id)
      can [:manage], Image
      can [:manage], Variant
      can [:manage], ProductProperty
      can [:manage], StockLocation
      can [:manage], StockItem
      #can [:manage], Order
      can [:manage], Preference
      can [:manage], Prototype
      can [:manage], Property
      can [:manage], OptionType
      can [:manage], Taxon
      can [:manage], Taxonomy
    end
  end
end
