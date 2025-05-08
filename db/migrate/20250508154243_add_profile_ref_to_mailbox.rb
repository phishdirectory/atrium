class AddProfileRefToMailbox < ActiveRecord::Migration[8.0]
   disable_ddl_transaction!

  def change
    add_reference :mailboxes, :profile, null: false, index: {algorithm: :concurrently}
  end
end
