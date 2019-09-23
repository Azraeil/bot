class ChangeItemContentToBeTextInPosts < ActiveRecord::Migration[5.2]
  def up
    change_column :posts, :item_content, :text
  end

  def down
    change_column :posts, :item_content, :string
  end
end
