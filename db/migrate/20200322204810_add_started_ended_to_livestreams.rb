class AddStartedEndedToLivestreams < ActiveRecord::Migration[5.2]
  def change
    add_column :livestreams, :started, :boolean
    add_column :livestreams, :ended, :boolean
  end
end
