class AddScoreToSongs < ActiveRecord::Migration[5.2]
  def change
    add_column :songs, :score, :integer, :default=>1
  end
end
