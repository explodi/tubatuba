class AddVideoEnabledToVideoFormats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_formats, :video_enabled, :boolean, :default=>true
  end
end
