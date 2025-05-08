class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :pd_id
      t.string :email
      t.string :first_name
      t.string :last_name
      # t.text :bio

      t.timestamps
    end
    add_index :profiles, :pd_id
  end
end
