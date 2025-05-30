class ProcessOrderJob < ApplicationJob
  queue_as :default

  def perform(json_string, user_id)
    ActiveRecord::Base.transaction do
      order_payload = JSON.parse(json_string)
      item_payload = order_payload["order_items"][0]
      user = User.find(user_id)
      # Derive IDs
      pack_id = order_payload["pack_id"]
      sale_channel_id = order_payload["id"]
      human_readable_id = pack_id || sale_channel_id

      order = Order.find_or_initialize_by(human_readable_id: human_readable_id)
      order.expected_item_count = order.expected_item_count || 1

      items = order.order_items

      is_existing_order = !order.new_record?
      needs_more_items  = order.expected_item_count > items.count
      is_new_order_item = !items.any? { |item| item.sale_channel_id == sale_channel_id }



      if !is_existing_order && pack_id
        client = MeliApiClient.new(user.meli_account)
        pack_data = client.get("packs/#{pack_id}")
        order.expected_item_count = pack_data["orders"].size
      end

      if !is_existing_order
        order.assign_attributes(
          user: user,
          pack_id: pack_id,
          source_channel: :mercadolibre,
          status: order_payload["status"],
        )

        order.save!

        OrderItem.create!(
          order: order,
          item_id: item_payload["item"]["id"],
          sale_channel_id: sale_channel_id,
          seller_sku: item_payload["item"]["seller_sku"],
          quantity: item_payload["quantity"],
          billable_amount: order_payload["total_amount"],
          )

        shipment = Shipment.create!(
          order: order,
          meli_id: order_payload.dig("shipping", "id")
        )

        ProcessShipmentJob.set(wait: 3.minutes).perform_later(shipment)
      elsif is_existing_order && needs_more_items && is_new_order_item
        OrderItem.create!(
          order: order,
          item_id: item_payload["item"]["id"],
          sale_channel_id: sale_channel_id,
          seller_sku: item_payload["item"]["seller_sku"],
          quantity: item_payload["quantity"],
          billable_amount: order_payload["total_amount"],
        )
      end
    end
  end
end
