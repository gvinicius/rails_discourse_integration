class CreateDiscourseGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :discourse_group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :discourse_group_id, null: false
      t.string :discourse_group_name, null: false

      t.timestamps
    end

    add_index :discourse_group_memberships,
              %i[user_id discourse_group_id],
              unique: true,
              name: "index_discourse_memberships_on_user_and_group"
  end
end
