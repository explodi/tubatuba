class AddErrorCountToSecurityCameras < ActiveRecord::Migration[5.2]
  def change
    add_column :security_cameras, :error_count, :integer, :default=>0
  end
end
