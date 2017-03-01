module Spree
	module Admin
		ReportsController.class_eval do 

			def initialize
				super 
				ReportsController.add_available_report!(:sales_total)
				# ReportsController.add_available_report!(:products_sale_report)
				ReportsController.add_available_report!(:store_details_report)
			end

			def store_details_report
				per_page = 25
				p params[:page]
				unless params[:page].blank?
					# p params[:page]
					page = params[:page].to_i
					start = per_page * ( params[:page].to_i - 1)
				else
					start = 0
				end

				if params[:download_excel]
					@date1 = params[:orders_completed_start].to_date
					@date2 = params[:orders_completed_end].to_date
				elsif params[:orders_completed_end].present? && params[:orders_completed_start].present?
					@date1 = params[:orders_completed_start].to_date
					@date2 = params[:orders_completed_end].to_date
					if @date1 > @date2
						redirect_to :back, notice: "From date can not be greater than To date. Displaying last 2 weeks records"
					end
				else
					@date1 =  2.weeks.ago.to_date + 1
					@date2 = Date.today
				end

				p @date1
				p @date2
			
				@store_sale_array = []
				if params[:download_excel]
					Merchant::Store.all.each do |merchant|
						p "0000000000000000000000000000"
						Hash merchant_hash = Hash.new
						merchant_hash["id".to_sym] = merchant.id
						merchant_hash["name".to_sym] = merchant.name
						merchant_hash["sales_amount".to_sym] =  Spree::LineItem.where("DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).collect{|obj| obj.price * obj.quantity}.sum.to_f.round(2)

						merchant_hash["tax".to_sym] = Spree::LineItem.where("DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).select("spree_line_items.quantity,spree_line_items.price,spree_line_items.tax_category_id").collect{|x| Spree::TaxCategory.find(x.tax_category_id).tax_rates.first.amount * x.price * x.quantity}.sum.to_f.round(2)
						@store_sale_array.push(merchant_hash)
					end
				else
					Merchant::Store.all.offset(start).limit(per_page).each do |merchant|
						Hash merchant_hash = Hash.new
						merchant_hash["id".to_sym] = merchant.id
						merchant_hash["name".to_sym] = merchant.name
						merchant_hash["sales_amount".to_sym] = Spree::LineItem.where("DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).collect{|obj| obj.price * obj.quantity}.sum.to_f.round(2)

						merchant_hash["tax".to_sym] = Spree::LineItem.where("DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).select("spree_line_items.quantity,spree_line_items.price,spree_line_items.tax_category_id").collect{|x| Spree::TaxCategory.find(x.tax_category_id).tax_rates.first.amount * x.price * x.quantity}.sum.to_f.round(2)
						@store_sale_array.push(merchant_hash)
					end
				end

				@total_merchant_count = Merchant::Store.all.count / per_page
				if (Merchant::Store.all.count % per_page) != 0
					@total_merchant_count = @total_merchant_count + 1
				end

				if params[:download_excel] && eval(params[:download_excel])
					request.format = "xls"
					respond_to do |format|
						format.xls #{ send_file(file_name) }
					end
				end

			end

			def store_sale_product

				@date1 = params[:orders_completed_start].to_date
				@date2 = params[:orders_completed_end].to_date
				@store_id = params[:store_id]

				@sale_product =  Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: @store_id}).select("spree_line_items.variant_id, spree_line_items.quantity").group("spree_line_items.variant_id").sum("spree_line_items.quantity")
				p @sale_product
				@product_sale_arr = []
				@return_item_arr = []
				 @sale_product.keys.each do |variant_id|
					variant = Spree::Variant.find(variant_id)
					Hash product_sale_hash = Hash.new
					product_sale_hash["name".to_sym] = variant.product.name
					product_sale_hash["price".to_sym] = variant.price.to_f.round(2)
					product_sale_hash["tax_rate".to_sym] = variant.tax_category_id.present? ? variant.tax_category.tax_rates.first.amount.to_f : variant.product.tax_category.tax_rates.first.amount.to_f 
					product_sale_hash["option_name".to_sym] = variant.option_name
					product_sale_hash["qty".to_sym] = @sale_product[variant_id]

					@product_sale_arr.push(product_sale_hash)
				 end
				
				@return_items =  Spree::CustomerReturnItem.where("DATE(updated_at) >= ? AND DATE(updated_at) <= ? AND store_id = ? AND status = ?",@date1,@date2, @store_id,"refunded").group("customer_return_items.line_item_id").sum("customer_return_items.return_quantity")

				unless @return_items.blank?
					@return_items.keys.each do |return_item|
						p return_item
						Hash return_item_hash = Hash.new
						variant = Spree::LineItem.find(return_item).variant
						return_item_hash["name".to_sym] = variant.product.name
						return_item_hash["price".to_sym] = variant.price.to_f.round(2)
						return_item_hash["tax_rate".to_sym] = variant.tax_category_id.present? ? variant.tax_category.tax_rates.first.amount.to_f : variant.product.tax_category.tax_rates.first.amount.to_f 
						# return_item_hash["option_name".to_sym] = variant.option_name
						return_item_hash["qty".to_sym] = @return_items[return_item]

						 @return_item_arr.push(return_item_hash)
					end
				end
				p "((((((((((((((((((((((((((((((((((((((((((("
				p @return_item_arr
				render json: {
					product: @product_sale_arr.as_json(),
					return_items: @return_item_arr.as_json()
				}
			end

			def products_sale_report
				if params[:orders_completed_start].present?
					@date1 = params[:orders_completed_start].to_date
					@date2 = params[:orders_completed_end].to_date
				else
					@date1 =  2.weeks.ago.to_date + 1
					@date2 = Date.today
				end
				if params[:brand_name].present?
					@brand = params[:brand_name]
				else
					@brand = "Select Brand"
				end

				@store = params[:store_name].present? ? Merchant::Store.find(params[:store_name]).name.to_s : "Select Store"
				@category = params[:category_name].present? ? Spree::Taxon.find(params[:category_name]).name : "Select Category"
				@email = params[:user_email].present? ? params[:user_email] : ""
				@product_name = params[:product_name].present? ?  params[:product_name] : ""
				@max_price = (params[:max_price].present? && params[:max_price].to_i > 0) ?  params[:max_price] : 0
				@min_price = (params[:min_price].present? && params[:min_price].to_i > 0) ?  params[:min_price] : 0
			
				# if params[:orders_completed_start].present?
				# 	@date1 = params[:orders_completed_start].to_date
				# else
				# 	@date1 = 2.weeks.ago
				# end

				# if params[:orders_completed_end].present?
				# 	@date2 = params[:orders_completed_end].to_date
				# else
				# 	@date2 = Date.today
				# end
				@merchants = Merchant::Store.all
				@taxons = Spree::Taxon.where(parent_id: nil)
				@brand_names = Spree::Property.where(name: "Brand").first.product_properties

				@search = Sunspot.search(Spree::LineItem) do
					@page = params[:page].present? ? params[:page] : 1
					@per_page = 25
					with(:store_id, params[:store_name].to_i) if params[:store_name].present?
					all_of do
						if params[:orders_completed_start].blank? && params[:orders_completed_end].blank?
							@date_start = Date.today - 14
							@date_end = Date.today
						else
							@date_start = params[:orders_completed_start].to_date
							@date_end = params[:orders_completed_end].to_date
						end
						with(:updated_at).greater_than_or_equal_to(@date_start)
						with(:updated_at).less_than_or_equal_to(@date_end)
					end
					with(:email,params[:user_email]) if params[:user_email].present?
					with(:taxon_ids, params[:category_name]) if params[:category_name].present?
					with(:brand_names,params[:brand_name]) if params[:brand_name].present?
					with(:product_names, params[:product_name]) if params[:product_name].present?
					with(:product_price, params[:min_price]..params[:max_price]) if params[:max_price].present? && params[:max_price].to_i > 0 && params[:min_price].present? && params[:min_price].to_i > 0
					paginate(:page => @page, :per_page => @per_page)
				end
				@line_items = @search.results
				p "***********************************************"
				# p @search.results
				# p @line_items
				params[:q] = {} unless params[:q]
				if params[:q][:orders_completed_at_gt].blank?
					params[:q][:orders_completed_at_gt] = Time.zone.now.beginning_of_month
				else
					params[:q][:orders_completed_at_gt] = Time.zone.parse(params[:q][:orders_completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
				end

				if params[:q] && !params[:q][:orders_completed_at_lt].blank?
					params[:q][:orders_completed_at_lt] = Time.zone.parse(params[:q][:orders_completed_at_lt]).end_of_day rescue ""
				end

				params[:q][:s] ||= "orders_completed_at desc"
				
				@search = Spree::Product.ransack(params[:q])
				@products = @search.result(distinct: true).joins(:orders).where(spree_orders: {state: "complete"}).page(params[:page]).
					per(30)
				@merchant = Merchant::Store.all

				if params[:download_excel] && eval(params[:download_excel])
					request.format = "xls"
					respond_to do |format|
						format.xls #{ send_file(file_name) }
					end
				end
				
			end





			def download_csv_file_for_store
				report_download_csv_file(params[:q][:orders_completed_at_gt], params[:q][:orders_completed_at_lt])
			end

			def report_download_csv_file(start_date,end_date)
				start_date = Date.strptime(start_date, "%m/%d/%Y")
				end_date  =  Date.strptime(end_date, "%m/%d/%Y")

				header = 'Store Name, Total sales amount, Total sales tax , total discount earned by PYKLOCAL, Delivery charges adjustments , Total Net Pay to the store'
				file_name = "Store_order_details#{Date.today}.csv"
				File.open(file_name, "w") do |writer|
					writer << header
					writer << "\n"
					Merchant::Store.each do |merchant|
						merchant.orders.where("DATE(created_at) >= ? AND DATE(created_at) <= ? ", start_date, end_date).each do |order|
							csv_value = order.sum(:total), order.keyword, order.user.try(:email),order.presented_link, order.completetion_number, order.completion_callback,order.cashback.to_f,order.zip.to_i,order.created_at.strftime("%B-%d-%Y  %T")
								writer << csv_value.map(&:inspect).join(', ')
								writer << "\n"
						end
					end
				end             
					send_file(file_name)
					# NotifyUser.send_orders_csv_to_admin(file_name).deliver
			end  

		end
	end
end

