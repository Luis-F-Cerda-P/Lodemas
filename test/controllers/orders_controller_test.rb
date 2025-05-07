require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
    @user = User.create(email_address: "real_user@real.com", password: "realMEANSreal")
    post session_url, params: { email_address: @user.email_address, password: @user.password }
  end

  test "should get index" do
    get orders_url
    assert_response :success
  end

  test "should get new" do
    get new_order_url
    assert_response :success
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: { order: { source_channel: @order.source_channel, human_readable_id: @order.human_readable_id, pack_id: @order.pack_id, sale_channel_id: @order.sale_channel_id, status: @order.status, user_id: @order.user_id } }
    end

    assert_redirected_to order_url(Order.last)
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), params: { order: { source_channel: @order.source_channel, human_readable_id: @order.human_readable_id, pack_id: @order.pack_id, sale_channel_id: @order.sale_channel_id, status: @order.status, user_id: @order.user_id } }
    assert_redirected_to order_url(@order)
  end

  test "should destroy order" do
    assert_difference("Order.count", -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end
end
