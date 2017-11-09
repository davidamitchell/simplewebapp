class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :owner
      t.timestamps null: false
      t.string :uid, null: false
    end
    add_index :accounts, [ :uid ], :unique => true
  end
end
