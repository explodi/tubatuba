class AddScreenshotUuidToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :screenshot_uuid, :string
  end
end
