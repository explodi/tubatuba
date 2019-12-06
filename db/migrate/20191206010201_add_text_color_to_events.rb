class AddTextColorToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :text_color, :string
  end
end
