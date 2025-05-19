class OrderItem < ApplicationRecord
  belongs_to :order

  after_save :check_billable_amount_change

  private

  def check_billable_amount_change
    if saved_change_to_billable_amount?
      order.run_ready_for_billing_check!
    end
  end
end
