class UpdateOrdersForBillingFeatures < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :billable_amount, :integer
    add_column :orders, :expected_item_count, :integer
    remove_column :orders, :sale_channel_id, :integer
  end
end
