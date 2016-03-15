require 'test_helper'

class DeliveriesControllerTest < ActionController::TestCase
  setup do
    @delivery = deliveries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:deliveries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delivery" do
    assert_difference('Delivery.count') do
      post :create, delivery: { availability_id: @delivery.availability_id, commission: @delivery.commission, delivery_request_id: @delivery.delivery_request_id, payin_id: @delivery.payin_id, status: @delivery.status, total: @delivery.total, validation_code: @delivery.validation_code }
    end

    assert_redirected_to delivery_path(assigns(:delivery))
  end

  test "should show delivery" do
    get :show, id: @delivery
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @delivery
    assert_response :success
  end

  test "should update delivery" do
    patch :update, id: @delivery, delivery: { availability_id: @delivery.availability_id, commission: @delivery.commission, delivery_request_id: @delivery.delivery_request_id, payin_id: @delivery.payin_id, status: @delivery.status, total: @delivery.total, validation_code: @delivery.validation_code }
    assert_redirected_to delivery_path(assigns(:delivery))
  end

  test "should destroy delivery" do
    assert_difference('Delivery.count', -1) do
      delete :destroy, id: @delivery
    end

    assert_redirected_to deliveries_path
  end
end
