class CreateDiscourseWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :discourse_webhook_events do |t|
      t.string :discourse_event_id, null: false
      t.string :event_type, null: false
      t.string :event_name
      t.json :payload, null: false, default: {}
      t.string :delivery_status, null: false, default: "pending"
      t.text :delivery_error

      t.timestamps
    end

    add_index :discourse_webhook_events, :discourse_event_id, unique: true
    add_index :discourse_webhook_events, :event_type
    add_index :discourse_webhook_events, :delivery_status
  end
end
