Deface::Override.new(
  :virtual_path => "spree/layouts/admin",
  :name => "admin-seller-tab",
  :insert_bottom => "[data-hook='admin_tabs']",
  :partial => "spree/admin/hooks/seller_tab",
  :disabled => false
)