class AddEventbriteUrlToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :eventbrite_url, :string
  end
end
