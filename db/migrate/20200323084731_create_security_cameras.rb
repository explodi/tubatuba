class CreateSecurityCameras < ActiveRecord::Migration[5.2]
  def change
    create_table :security_cameras do |t|
      t.string :ip_str
      t.integer :port

      t.timestamps
    end
  end
end
