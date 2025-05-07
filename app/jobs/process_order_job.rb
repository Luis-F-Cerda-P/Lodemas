class ProcessOrderJob < ApplicationJob
  queue_as :default

  def perform(json_string, user_id)
    payload = JSON.parse(json_string)
    user = User.find(user_id)

    # Derive IDs
    pack_id = payload["pack_id"]
    sale_channel_id = payload["id"]
    human_readable_id = pack_id || sale_channel_id

    order = Order.find_or_initialize_by(human_readable_id: human_readable_id)
    order.assign_attributes(
      user: user,
      pack_id: pack_id,
      sale_channel_id: sale_channel_id,
      source_channel: :mercadolibre
    )
    order.save!

    payload["order_items"].each do |item_data|
    item = item_data["item"]
      OrderItem.find_or_create_by!(
        order: order,
        item_id: item["id"]
      ) do |order_item|
        order_item.seller_sku = item["seller_sku"]
        order_item.quantity = item_data["quantity"]
      end
    end


    # Create or update shipment
    shipping_id = payload.dig("shipping", "id")
    if shipping_id
      shipment = Shipment.find_or_initialize_by(order: order)
      shipment.meli_id = shipping_id
      shipment.save!
    end
  end
end
