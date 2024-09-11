class CreateLps < ActiveRecord::Migration[7.1]
  def change
    create_table :lps do |t|
      t.string :name
      t.string :description
      t.references :artist, null: true, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
