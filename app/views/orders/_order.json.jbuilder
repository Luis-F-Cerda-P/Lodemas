json.extract! order, :id, :user_id, :pack_id, :sale_channel_id, :human_readable_id, :source_channel, :status, :created_at, :updated_at
json.url order_url(order, format: :json)
