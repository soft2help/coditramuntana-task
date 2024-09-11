class CreateSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :songs do |t|
      t.string :title
      t.references :lp, null: true, foreign_key: true

      t.timestamps
    end
    # Then add the foreign key with `on_delete: :nullify`
    add_foreign_key :songs, :lps, on_delete: :nullify
  end
end
