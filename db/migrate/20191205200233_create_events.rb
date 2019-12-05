class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.datetime :start
      t.datetime :end
      t.string :address
      t.string :name
      t.decimal :lat, precision:10, scale:6
      t.decimal :lng, precision:10, scale:6

      t.timestamps
    end
  end
end
