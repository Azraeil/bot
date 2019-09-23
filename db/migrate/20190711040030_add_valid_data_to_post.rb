class AddValidDataToPost < ActiveRecord::Migration[5.2]
  def change
    add_column(:posts, :valid_data, :boolean, :default => false)
  end
end
