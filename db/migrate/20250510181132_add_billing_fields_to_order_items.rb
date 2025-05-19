class AddBillingFieldsToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :sale_channel_id, :integer
    add_column :order_items, :billable_amount, :integer
  end
end
