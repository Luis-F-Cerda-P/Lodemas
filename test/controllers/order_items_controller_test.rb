require "test_helper"

class OrderItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order_item = order_items(:one)
    @user = User.create(email_address: "real_user@real.com", password: "realMEANSreal")
    post session_url, params: { email_address: @user.email_address, password: @user.password }
  end

  test "should get index" do
    get order_items_url
    assert_response :success
  end

  test "should get new" do
    get new_order_item_url
    assert_response :success
  end

  test "should create order_item" do
    assert_difference("OrderItem.count") do
      post order_items_url, params: { order_item: { item_id: @order_item.item_id, order_id: @order_item.order_id, sale_channel_id: @order_item.sale_channel_id, quantity: @order_item.quantity, seller_sku: @order_item.seller_sku } }
    end

    assert_redirected_to order_item_url(OrderItem.last)
  end

  test "should show order_item" do
    get order_item_url(@order_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_item_url(@order_item)
    assert_response :success
  end

  test "should update order_item" do
    patch order_item_url(@order_item), params: { order_item: { sale_channel_id: @order_item.sale_channel_id, item_id: @order_item.item_id, order_id: @order_item.order_id, quantity: @order_item.quantity, seller_sku: @order_item.seller_sku } }
    assert_redirected_to order_item_url(@order_item)
  end

  test "should destroy order_item" do
    assert_difference("OrderItem.count", -1) do
      delete order_item_url(@order_item)
    end

    assert_redirected_to order_items_url
  end
end
