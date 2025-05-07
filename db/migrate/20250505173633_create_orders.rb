class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :pack_id
      t.integer :sale_channel_id
      t.string :human_readable_id
      t.integer :source_channel, default: 0
      t.string :status

      t.timestamps
    end
  end
end
