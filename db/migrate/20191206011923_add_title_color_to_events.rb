class AddTitleColorToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :title_color, :string
  end
end
