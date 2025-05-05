class CreateEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :emails do |t|
      t.references :mailbox, null: false, foreign_key: true
      t.string :subject, null: false
      t.string :sender, null: false
      t.string :recipient, null: false
      t.boolean :read, default: false
      t.datetime :sent_at
      t.datetime :received_at
      t.boolean :archived, default: false
      t.boolean :starred, default: false
      t.string :message_id
      t.string :in_reply_to
      t.string :references

      t.timestamps
    end

    add_index :emails, :message_id, unique: true
    add_index :emails, :in_reply_to
  end
end
