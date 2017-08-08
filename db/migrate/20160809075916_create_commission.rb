class CreateCommission < ActiveRecord::Migration[5.0]
  def change
    create_table :commissions do |t|
      t.float :percentage

      t.timestamps
    end
  end
end
