class CreateVideoFlyers < ActiveRecord::Migration[5.2]
  def change
    create_table :video_flyers do |t|
      t.integer :width
      t.integer :height
      t.integer :event_id
      t.string :uuid

      t.timestamps
    end
  end
end
