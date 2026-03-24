require "test_helper"

class DashboardIntegrationTest < ActionDispatch::IntegrationTest
  # Mock controller to test full rendering
  class TestController < SolidCacheDashboard::ApplicationController
    def pagination_test
      # Create test data
      50.times do |i|
        SolidCache::Entry.create!(
          key: "test_key_#{i}",
          value: "test_value_#{i}",
          key_hash: 1000 + i,
          byte_size: 100
        )
      end
      
      @pagy, @cache_entries = pagy(SolidCache::Entry.order(created_at: :desc), items: 10)
      @cache_entries = SolidCacheDashboard.decorate(@cache_entries)
      
      render inline: <<~ERB
        <%= render partial: "solid_cache_dashboard/application/pagination",
                   locals: { 
                     pagy: @pagy, 
                     path_for_page: ->(page) { "/test?page=\#{page}" },
                     item_name: "entry"
                   } %>
      ERB
    end
  end

  setup do
    # Clear data
    SolidCache::Entry.destroy_all
    
    # Setup routes
    Rails.application.routes.draw do
      get 'pagination_test' => 'dashboard_integration_test/test#pagination_test'
    end
  end

  teardown do
    SolidCache::Entry.destroy_all
  end

  test "pagination renders correctly with Pagy version #{Pagy::VERSION}" do
    get '/pagination_test'
    
    assert_response :success
    
    # Check that pagination elements are present
    assert_select "nav[aria-label='Pagination']", count: 1
    
    # Check page info text
    assert_match /Showing \d+ to \d+ of 50 entries/, response.body
    
    # Check that page links exist
    assert_select "a[href*='page=']"
    
    # Verify no errors about undefined methods
    refute_match /undefined method/, response.body
    refute_match /NoMethodError/, response.body
  end
  
  test "navigation between pages works correctly" do
    get '/pagination_test?page=2'
    
    assert_response :success
    
    # Should have a link to previous page
    assert_select "a[href='/test?page=1']"
    
    # Should have a link to next page
    assert_select "a[href='/test?page=3']"
  end
end
