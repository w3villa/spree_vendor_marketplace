class CreateCommission < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
      t.float :percentage

      t.timestamps
    end
  end
end
