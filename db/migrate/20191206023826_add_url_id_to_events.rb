class AddUrlIdToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :url_id, :string
  end
end
