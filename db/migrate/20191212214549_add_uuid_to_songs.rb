class AddUuidToSongs < ActiveRecord::Migration[5.2]
  def change
    add_column :songs, :uuid, :string
  end
end
