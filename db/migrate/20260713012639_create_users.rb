class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :okta_uid, null: false
      t.string :email, null: false
      t.string :name, null: false
      t.string :discourse_username, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :users, :okta_uid, unique: true
    add_index :users, :email, unique: true
    add_index :users, :discourse_username, unique: true
  end
end
