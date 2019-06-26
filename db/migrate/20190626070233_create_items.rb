class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.integer :postitem_id
      t.string :product_name
      t.integer :price
      t.timestamps
    end
  end
end
