module Spree
	Api::V1::OptionTypesController.class_eval do 

		skip_before_filter :authenticate_user, only: [:index]

		def index
			if current_spree_user.has_spree_role?("merchant")
				if params[:ids]
					@option_types = Spree::OptionType.includes(:option_values).where(id: params[:ids].split(','))
				else
					@option_types = Spree::OptionType.includes(:option_values).load.ransack(params[:q]).result
				end
			else
				if params[:ids]
	        @option_types = Spree::OptionType.includes(:option_values).accessible_by(current_ability, :read).where(id: params[:ids].split(','))
	      else
	        @option_types = Spree::OptionType.includes(:option_values).accessible_by(current_ability, :read).load.ransack(params[:q]).result
	      end
	    end
      respond_with(@option_types)
		end

	end
end