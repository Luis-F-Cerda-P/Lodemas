class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_one :shipment, dependent: :destroy

  has_one_attached :bill

  enum :source_channel, { mercadolibre: 0 }

  def run_ready_for_billing_check!
    # you can run your logic here or trigger a job
    if ready_for_billing?
      calculate_billable_amount
      GenerateBillJob.perform_later(self)
    end
  end

  def ready_for_billing?
    expected_item_count == order_items.count &&
      order_items.all? { |item| item.billable_amount.present? && item.billable_amount > 0 } &&
      shipment&.billable_amount.present? &&
      !bill.attached?
  end

  private

  def calculate_billable_amount
    total = order_items.sum(:billable_amount) + shipment.billable_amount
    update!(billable_amount: total)
  end
end
