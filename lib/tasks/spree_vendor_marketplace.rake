namespace :spree_vendor_marketplace do
  def load_environment
    puts "Loading environment..."
    require File.join(Rails.root, 'config', 'environment')
  end

  desc "Creates wholesale role"
  task :create_role do
    load_environment

    name = "merchant"
    role = Spree::Role.find_by_name(name) rescue nil
    if role
      puts "Role exists!"
    else
      role = Spree::Role.create(:name => name)
      puts "Role created!"
    end

    puts role.inspect
  end
end
