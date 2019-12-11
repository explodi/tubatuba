class CreateVideoFormats < ActiveRecord::Migration[5.2]
  def change
    create_table :video_formats do |t|
      t.integer :width
      t.integer :height
      t.string :name
      t.boolean :title
      t.boolean :line_up
      t.boolean :address
      t.boolean :date

      t.timestamps
    end
  end
end
