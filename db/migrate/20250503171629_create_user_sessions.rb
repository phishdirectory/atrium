class CreateUserSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sessions do |t|
      t.string :pd_id, null: false
      t.text :user_data_ciphertext
      t.string :session_token_ciphertext
      t.string :session_token_bidx
      t.string :fingerprint
      t.string :device_info
      t.string :string
      t.string :os_info
      t.string :timezone
      t.string :ip
      t.datetime :expiration_at, null: false
      t.datetime :last_seen_at
      t.datetime :signed_out_at
      t.float :latitude
      t.float :longitude
      t.timestamps
    end

    add_index :user_sessions, :pd_id
  end
end
