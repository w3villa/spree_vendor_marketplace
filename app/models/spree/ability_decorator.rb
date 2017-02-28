module Spree
	Ability.class_eval do 
	 	alias_method :old_initialize, :initialize

	  def initialize(user)
	  	old_initialize user
	  	puts abilities
	  	self.clear_aliased_actions

      # override cancan default aliasing (we don't want to differentiate between read and index)
      alias_action :delete, to: :destroy
      alias_action :edit, to: :update
      alias_action :new, to: :create
      alias_action :new_action, to: :create
      alias_action :show, to: :read

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
end