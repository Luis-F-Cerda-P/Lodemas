require "test_helper"

class MeliConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create(email_address: "real_user@real.com", password: "realMEANSreal")
    post session_url, params: { email_address: @user.email_address, password: @user.password }
  end
  test "should get new" do
    get meli_connections_new_url
    assert_response :success
  end

  # test "should get authorize" do
  #   get meli_connections_authorize_url
  #   assert_response :success
  # end
end
