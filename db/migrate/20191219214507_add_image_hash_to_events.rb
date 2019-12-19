class AddImageHashToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :image_hash, :string
  end
end
