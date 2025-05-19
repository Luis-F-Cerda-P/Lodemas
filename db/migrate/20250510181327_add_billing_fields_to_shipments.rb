class AddBillingFieldsToShipments < ActiveRecord::Migration[8.0]
  def change
    add_column :shipments, :logistic_type, :integer
    add_column :shipments, :billable_amount, :integer
    add_column :shipments, :destination, :string
    add_column :shipments, :delivery_deadline, :datetime
  end
end
