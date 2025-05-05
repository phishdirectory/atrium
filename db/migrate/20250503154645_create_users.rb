class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :password_digest, null: false

      t.integer :access_level, default: 0, null: false
      t.boolean :pretend_is_not_admin, default: false, null: false
      t.integer :session_duration_seconds, default: 2592000, null: false

      t.timestamps
    end
  end
end
