require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @product = products(:shoes)
    @product.update(user: @user)

    # Log in using Rails 8 authentication
    post session_url, params: {
      email_address: @user.email_address,
      password: "L123456" # Assuming this is the fixture password
    }
  end

  test "should get index showing only current user's products" do
    other_product = products(:pants)
    # other_product.update(user: @other_user)

    get products_url
    assert_response :success

    # Should include user's product
    assert_select "#product_#{@product.id}"
    # Should not include other user's product
    assert_select "#product_#{other_product.id}", 0
  end

  test "should show user's product" do
    get product_url(@product)
    assert_response :success
  end

  test "should not show other user's product" do
    other_product = products(:pants)
    other_product.update(user: @other_user)

    get product_url(other_product)
    assert_response :not_found # Assuming you're raising ActiveRecord::RecordNotFound
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product associated with current user" do
    assert_difference("@user.products.count") do
      post products_url, params: {
        product: {
          name: "New Product",
          inventory_count: 5
        }
      }
    end

    product = Product.last
    assert_equal @user.id, product.user_id
    assert_redirected_to product_url(product)
  end

  test "should get edit for user's product" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update user's product" do
    patch product_url(@product), params: {
      product: {
        name: "Updated Product Name"
      }
    }

    @product.reload
    assert_equal "Updated Product Name", @product.name
    assert_redirected_to product_url(@product)
  end

  test "should destroy user's product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end

  test "should not be able to manipulate other user's products" do
    other_product = products(:pants)
    other_product.update(user: @other_user)

    # Try to edit
    get edit_product_url(other_product)
    assert_response :not_found

    # Try to update
    patch product_url(other_product), params: { product: { name: "Hacked Product" } }
    assert_response :not_found
    other_product.reload
    assert_not_equal "Hacked Product", other_product.name

    # Try to destroy
    assert_no_difference("Product.count") do
      delete product_url(other_product)
    end
    assert_response :not_found
  end

  test "should redirect to login when not authenticated" do
    # Logout first
    delete session_url

    # Try accessing products
    get products_url
    assert_redirected_to new_session_path
  end
end
