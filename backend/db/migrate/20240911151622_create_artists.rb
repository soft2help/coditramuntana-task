class CreateArtists < ActiveRecord::Migration[7.1]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
    add_index :artists, :name, unique: true
  end
end
