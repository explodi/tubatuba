class AddTitleToLivestreams < ActiveRecord::Migration[5.2]
  def change
    add_column :livestreams, :title, :string
  end
end
