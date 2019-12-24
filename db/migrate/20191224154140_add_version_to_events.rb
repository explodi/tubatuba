class AddVersionToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :version, :string
  end
end
