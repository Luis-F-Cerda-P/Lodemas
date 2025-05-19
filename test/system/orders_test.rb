require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @order = orders(:one)
    @user = User.create(email_address: "real_user@real.com", password: "realMEANSreal")
    visit new_session_url
    find("#email_address").set(@user.email_address)
    find("#password").set(@user.password)
    click_button "Ingresar"
  end

  test "visiting the index" do
    visit orders_url
    assert_selector "h1", text: "Orders"
  end

  test "should create order" do
    visit orders_url
    click_on "New order"

    fill_in "Source channel", with: @order.source_channel
    fill_in "Human readable", with: @order.human_readable_id
    fill_in "Pack", with: @order.pack_id
    fill_in "Status", with: @order.status
    fill_in "User", with: @order.user_id
    click_on "Create Order"

    assert_text "Order was successfully created"
    click_on "Back"
  end

  test "should update Order" do
    visit order_url(@order)
    click_on "Edit this order", match: :first

    fill_in "Source channel", with: @order.source_channel
    fill_in "Human readable", with: @order.human_readable_id
    fill_in "Pack", with: @order.pack_id
    fill_in "Status", with: @order.status
    fill_in "User", with: @order.user_id
    click_on "Update Order"

    assert_text "Order was successfully updated"
    click_on "Back"
  end

  test "should destroy Order" do
    visit order_url(@order)
    accept_confirm { click_on "Destroy this order", match: :first }

    assert_text "Order was successfully destroyed"
  end
end
