require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  class TestController < SolidCacheDashboard::ApplicationController
    def index
      collection = SolidCache::Entry.all
      @pagy, @records = pagy(collection, items: 25)
      
      render json: {
        pagy_class: @pagy.class.name,
        total_count: @pagy.count,
        current_page: @pagy.page,
        has_previous: @pagy.respond_to?(:prev) ? !!@pagy.prev : !!@pagy.previous,
        has_next: !!@pagy.next,
        limit: @pagy.respond_to?(:limit) ? @pagy.limit : @pagy.items
      }
    end
  end

  tests TestController

  setup do
    # Create some test data
    10.times do |i|
      SolidCache::Entry.create!(
        key: "key_#{i}",
        value: "value_#{i}",
        key_hash: i,
        byte_size: 100
      )
    end

    # Setup routes
    Rails.application.routes.draw do
      get 'test' => 'application_controller_test/test#index'
    end
  end

  teardown do
    SolidCache::Entry.destroy_all
  end

  test "pagy wrapper creates correct pagy object for current version" do
    get :index
    
    json = JSON.parse(response.body)
    
    assert_response :success
    
    if SolidCacheDashboard.pagy_43_or_newer?
      assert_match(/Pagy::Offset/, json['pagy_class'])
      assert_equal 25, json['limit']
    else
      assert_match(/Pagy/, json['pagy_class'])
      assert_equal 25, json['limit']
    end
    
    assert_equal 10, json['total_count']
    assert_equal 1, json['current_page']
  end

  test "pagy navigation attributes work correctly" do
    # Create more records to test pagination
    40.times do |i|
      SolidCache::Entry.create!(
        key: "extra_key_#{i}",
        value: "extra_value_#{i}",
        key_hash: 100 + i,
        byte_size: 100
      )
    end
    
    get :index
    json = JSON.parse(response.body)
    
    assert_equal 50, json['total_count']
    assert_equal false, json['has_previous'] # First page
    assert_equal true, json['has_next']     # Has more pages
  end
end
