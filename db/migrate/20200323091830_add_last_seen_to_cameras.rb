class AddLastSeenToCameras < ActiveRecord::Migration[5.2]
  def change
    add_column :security_cameras, :last_seen, :datetime
  end
end
