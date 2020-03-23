class AddLastPingToLivestreams < ActiveRecord::Migration[5.2]
  def change
    add_column :livestreams, :last_ping, :datetime
  end
end
