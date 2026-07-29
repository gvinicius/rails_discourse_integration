class CreateDiscourseGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :discourse_groups do |t|
      t.string :community_role_name, null: false
      t.string :discourse_group_name, null: false
      t.integer :discourse_group_id, null: false

      t.timestamps
    end

    add_index :discourse_groups, :community_role_name, unique: true
    add_index :discourse_groups, :discourse_group_id, unique: true
    add_index :discourse_groups, :discourse_group_name, unique: true
  end
end
