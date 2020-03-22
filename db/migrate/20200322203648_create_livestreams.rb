class CreateLivestreams < ActiveRecord::Migration[5.2]
  def change
    create_table :livestreams do |t|
      t.string :uuid

      t.timestamps
    end
  end
end
