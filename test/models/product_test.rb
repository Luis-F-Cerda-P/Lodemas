require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActionDispatch::TestProcess

  setup do
    @user = users(:one)
    @valid_attributes = {
      name: "Test Product",
      inventory_count: 10,
      user: @user
    }
  end

  test "sends email notification when back in stock" do
    product = products(:shoes)

    product.update(inventory_count: 0)

    assert_emails 2 do
      product.update(inventory_count: 99)
    end
  end

  test "should be valid with valid attributes" do
    product = Product.new(@valid_attributes)
    assert product.valid?
  end

  test "should require a name" do
    product = Product.new(@valid_attributes.merge(name: nil))
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "should require inventory_count to be non-negative" do
    product = Product.new(@valid_attributes.merge(inventory_count: -1))
    assert_not product.valid?
    assert_includes product.errors[:inventory_count], "must be greater than or equal to 0"
  end

  test "should allow inventory_count of zero" do
    product = Product.new(@valid_attributes.merge(inventory_count: 0))
    assert product.valid?
  end

  test "should belong to a user" do
    product = Product.new(@valid_attributes.merge(user: nil))
    assert_not product.valid?
    assert_includes product.errors[:user], "must exist"
  end

  test "should have rich text description" do
    product = Product.create(@valid_attributes)
    product.description = ActionText::Content.new("Product description")
    product.save
    assert_equal "Product description", product.description.to_plain_text
  end

  test "should be able to attach featured image" do
    product = Product.create(@valid_attributes)
    file = fixture_file_upload("test_image.jpg", "image/jpeg")

    assert_difference -> { ActiveStorage::Attachment.count } do
      product.featured_image.attach(file)
    end

    assert product.featured_image.attached?
  end

  test "should include Notifications module" do
    assert_includes Product.included_modules, Product::Notifications
  end
end
