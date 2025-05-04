require "test_helper"

class Api::MeliNotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_meli_notifications_create_url
    assert_response :success
  end
end
