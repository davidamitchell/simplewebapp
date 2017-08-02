class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
      t.integer :account_id
      t.integer :amount
      t.timestamps null: false
    end
  end
end
