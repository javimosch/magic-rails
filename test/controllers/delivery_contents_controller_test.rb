require 'test_helper'

class DeliveryContentsControllerTest < ActionController::TestCase
  setup do
    @delivery_content = delivery_contents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:delivery_contents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delivery_content" do
    assert_difference('DeliveryContent.count') do
      post :create, delivery_content: { id_delivery: @delivery_content.id_delivery, id_product: @delivery_content.id_product, quantity: @delivery_content.quantity, unit_price: @delivery_content.unit_price }
    end

    assert_redirected_to delivery_content_path(assigns(:delivery_content))
  end

  test "should show delivery_content" do
    get :show, id: @delivery_content
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @delivery_content
    assert_response :success
  end

  test "should update delivery_content" do
    patch :update, id: @delivery_content, delivery_content: { id_delivery: @delivery_content.id_delivery, id_product: @delivery_content.id_product, quantity: @delivery_content.quantity, unit_price: @delivery_content.unit_price }
    assert_redirected_to delivery_content_path(assigns(:delivery_content))
  end

  test "should destroy delivery_content" do
    assert_difference('DeliveryContent.count', -1) do
      delete :destroy, id: @delivery_content
    end

    assert_redirected_to delivery_contents_path
  end
end
