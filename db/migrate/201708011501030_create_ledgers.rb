class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
      t.integer :account_id
      t.integer :amount
      t.timestamps null: false
      t.string :uid, null: false
    end

    add_index :ledgers, [ :uid ], :unique => true
  end
end
