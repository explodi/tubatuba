class AddBackgroundUrlToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :background_url, :string
  end
end
