class CreateDiscourseIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :discourse_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :discourse_user_id
      t.string :discourse_username, null: false
      t.string :external_id, null: false
      t.datetime :last_synced_at
      t.string :last_sync_status, null: false, default: "pending"
      t.text :last_sync_error

      t.timestamps
    end

    add_index :discourse_identities, :external_id, unique: true
    add_index :discourse_identities, :discourse_user_id
    add_index :discourse_identities, :discourse_username
  end
end
