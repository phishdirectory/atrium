class CreateMailboxes < ActiveRecord::Migration[8.0]
  def change
    create_table :mailboxes do |t|
      t.string :name, null: false
      t.string :email_address, null: false

      t.timestamps
    end

    add_index :mailboxes, :email_address, unique: true
  end
end
