require "test_helper"

class MeliConnectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get meli_connections_new_url
    assert_response :success
  end

  test "should get authorize" do
    get meli_connections_authorize_url
    assert_response :success
  end

  test "should get destroy" do
    get meli_connections_destroy_url
    assert_response :success
  end
end
