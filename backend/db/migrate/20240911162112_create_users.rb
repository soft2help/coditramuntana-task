class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.text :roles, default: [].to_yaml  # Serialized array stored as text
      t.timestamps
    end

    add_index :users, :email, unique: true, name: "email_index"
  end
end
