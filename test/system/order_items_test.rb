require "application_system_test_case"

class OrderItemsTest < ApplicationSystemTestCase
  setup do
    @order_item = order_items(:one)
    @user = User.create(email_address: "real_user@real.com", password: "realMEANSreal")
    visit new_session_url
    find("#email_address").set(@user.email_address)
    find("#password").set(@user.password)
    click_button "Ingresar"
  end

  test "visiting the index" do
    visit order_items_url
    assert_selector "h1", text: "Order items"
  end

  test "should create order item" do
    visit order_items_url
    click_on "New order item"

    fill_in "Item", with: @order_item.item_id
    fill_in "Order", with: @order_item.order_id
    fill_in "Quantity", with: @order_item.quantity
    fill_in "Seller sku", with: @order_item.seller_sku
    click_on "Create Order item"

    assert_text "Order item was successfully created"
    click_on "Back"
  end

  test "should update Order item" do
    visit order_item_url(@order_item)
    click_on "Edit this order item", match: :first

    fill_in "Item", with: @order_item.item_id
    fill_in "Order", with: @order_item.order_id
    fill_in "Quantity", with: @order_item.quantity
    fill_in "Seller sku", with: @order_item.seller_sku
    click_on "Update Order item"

    assert_text "Order item was successfully updated"
    click_on "Back"
  end

  test "should destroy Order item" do
    visit order_item_url(@order_item)
    accept_confirm { click_on "Destroy this order item", match: :first }

    assert_text "Order item was successfully destroyed"
  end
end
