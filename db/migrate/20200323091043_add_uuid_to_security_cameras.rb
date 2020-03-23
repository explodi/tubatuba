class AddUuidToSecurityCameras < ActiveRecord::Migration[5.2]
  def change
    add_column :security_cameras, :uuid, :string
  end
end
