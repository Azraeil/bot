class AddRescueColumnsToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :need_rescue, :boolean, :default => false
    add_column :posts, :rescue_message, :text
  end
end
