class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.string :group, null: false
      t.timestamps
    end

    # Add indexes
    add_index :settings, :key, unique: true, name: "key_index"
    add_index :settings, :group, name: "group_index"
    add_index :settings, [:group, :key], unique: true, name: "group_key_index"
  end
end
