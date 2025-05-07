class CreateShipments < ActiveRecord::Migration[8.0]
  def change
    create_table :shipments do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :meli_id

      t.timestamps
    end
  end
end
