class AddItemContentToPost < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :item_content, :string
  end
end
