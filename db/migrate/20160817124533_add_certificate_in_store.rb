class AddCertificateInStore < ActiveRecord::Migration
  def change
    add_column :stores, :certificate_file_name, :string
    add_column :stores, :certificate_content_type, :string
    add_column :stores, :certificate_file_size, :integer
    add_column :stores, :certificate_updated_at, :datetime
  end
end
