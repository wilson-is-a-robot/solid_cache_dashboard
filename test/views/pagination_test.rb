require "test_helper"
require "action_view/test_case"

class PaginationViewTest < ActionView::TestCase
  include SolidCacheDashboard::ApplicationHelper
  
  setup do
    @path_for_page = ->(page) { "/test?page=#{page}" }
    @item_name = "entry"
  end

  test "pagination partial renders without errors for single page" do
    pagy = create_pagy(count: 10, page: 1, limit: 25)
    
    html = render_pagination(pagy)
    
    assert html.empty? # Should render nothing when pages <= 1
  end

  test "pagination partial renders navigation for multiple pages" do
    pagy = create_pagy(count: 100, page: 1, limit: 10)
    
    html = render_pagination(pagy)
    
    assert_includes html, "Showing"
    assert_includes html, "1 to 10 of 100"
    
    # Check previous button is disabled
    assert_includes html, 'class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-zinc-300 dark:border-zinc-600 bg-zinc-100'
    
    # Check next button is enabled
    assert_includes html, 'href="/test?page=2"'
  end

  test "series rendering works correctly" do
    pagy = create_pagy(count: 100, page: 5, limit: 10)
    
    html = render_pagination(pagy)
    
    # Should have links to pages
    assert_includes html, 'href="/test?page=1"'
    assert_includes html, 'href="/test?page=4"'
    assert_includes html, 'href="/test?page=6"'
    
    # Current page should be highlighted differently
    assert_includes html, 'text-blue-600 dark:text-blue-400'
  end

  test "previous attribute compatibility" do
    pagy = create_pagy(count: 100, page: 2, limit: 10)
    
    # Test that we can access previous page regardless of method name
    prev_page = pagy.respond_to?(:prev) ? pagy.prev : pagy.previous
    assert_equal 1, prev_page
  end

  private

  def create_pagy(count:, page:, limit:)
    if SolidCacheDashboard.pagy_43_or_newer?
      Pagy::Offset.new(count: count, page: page, limit: limit)
    else
      Pagy.new(count: count, page: page, items: limit)
    end
  end

  def render_pagination(pagy)
    render partial: "solid_cache_dashboard/application/pagination",
           locals: { pagy: pagy, path_for_page: @path_for_page, item_name: @item_name }
  rescue => e
    puts "Render error: #{e.message}"
    raise
  end
end
