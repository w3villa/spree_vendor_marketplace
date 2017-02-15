Deface::Override.new(
  :virtual_path => "spree/layouts/admin",
  :name => "admin-commission-tab",
  :insert_bottom => "[data-hook='admin_tabs']",
  :partial => "spree/admin/hooks/commission_tab",
  :disabled => false
)