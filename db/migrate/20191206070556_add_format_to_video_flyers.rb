class AddFormatToVideoFlyers < ActiveRecord::Migration[5.2]
  def change
    add_column :video_flyers, :format_string, :string
  end
end
