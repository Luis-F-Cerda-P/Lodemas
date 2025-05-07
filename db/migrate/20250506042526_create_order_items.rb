class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.string :item_id
      t.string :seller_sku
      t.integer :quantity

      t.timestamps
    end
  end
end
