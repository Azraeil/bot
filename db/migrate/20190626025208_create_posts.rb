class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :author
      t.string :url
      t.string :gaming_platform
      t.string :status      
      t.timestamp :created_time
      t.timestamp :updated_time

      t.timestamps
    end
  end
end
