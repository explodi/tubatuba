class AddDurationToSongs < ActiveRecord::Migration[5.2]
  def change
    add_column :songs, :duration, :float
  end
end
