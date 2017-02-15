json.array!(@stores) do |store|
  json.extract! store, :id, :name, :description, :manager_first_name, :manager_last_name, :phone_number, :type, :street_number, :city, :state, :zipcode, :country, :site_url, :terms_and_condition, :payment_information, :active
  json.url store_url(store, format: :json)
end
