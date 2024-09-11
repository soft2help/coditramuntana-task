class CreateApiKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys do |t|
      t.string :common_token_prefix
      t.string :encrypted_random_token_prefix
      t.string :token_digest, null: false
      t.string :name
      t.datetime :revoked_at
      t.datetime :expires_in
      t.references :bearer, polymorphic: true, index: true

      t.text :access_control_rules, default: {}.to_yaml
      t.text :permissions, default: {}.to_yaml
      t.timestamps
    end
    # Add unique index for token_digest
    add_index :api_keys, :token_digest, unique: true, name: "token_digest_index"
    # Add indexes for other fields
    add_index :api_keys, :name, name: "name_index"
    add_index :api_keys, :expires_in, name: "expires_in_index"
    add_index :api_keys, :revoked_at, name: "revoked_at_index"
  end
end
