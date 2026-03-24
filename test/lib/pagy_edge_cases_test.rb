require "test_helper"

class PagyEdgeCasesTest < ActiveSupport::TestCase
  test "handles empty collections correctly" do
    if SolidCacheDashboard.pagy_43_or_newer?
      pagy = Pagy::Offset.new(count: 0, page: 1, limit: 10)
    else
      pagy = Pagy.new(count: 0, page: 1, items: 10)
    end
    
    assert_equal 0, pagy.count
    assert_equal 1, pagy.page
    assert_equal 1, pagy.last
    refute pagy.next
    
    # Previous page check
    if pagy.respond_to?(:prev)
      refute pagy.prev
    else
      refute pagy.previous
    end
  end

  test "handles single page correctly" do
    if SolidCacheDashboard.pagy_43_or_newer?
      pagy = Pagy::Offset.new(count: 5, page: 1, limit: 10)
    else
      pagy = Pagy.new(count: 5, page: 1, items: 10)
    end
    
    assert_equal 5, pagy.count
    assert_equal 1, pagy.pages
    refute pagy.next
    
    # Series should still work
    series = SolidCacheDashboard.pagy_series(pagy)
    assert_equal ["1"], series
  end

  test "handles last page correctly" do
    if SolidCacheDashboard.pagy_43_or_newer?
      pagy = Pagy::Offset.new(count: 50, page: 5, limit: 10)
    else
      pagy = Pagy.new(count: 50, page: 5, items: 10)
    end
    
    assert_equal 5, pagy.page
    assert_equal 5, pagy.last
    refute pagy.next
    
    # Previous page check
    prev_page = pagy.respond_to?(:prev) ? pagy.prev : pagy.previous
    assert_equal 4, prev_page
  end

  test "series with gaps works correctly" do
    if SolidCacheDashboard.pagy_43_or_newer?
      pagy = Pagy::Offset.new(count: 1000, page: 50, limit: 10)
    else
      pagy = Pagy.new(count: 1000, page: 50, items: 10)
    end
    
    series = SolidCacheDashboard.pagy_series(pagy)
    
    # Should include gaps for large page counts
    assert series.include?(:gap)
    assert series.include?(1)      # First page
    assert series.include?(100)    # Last page
    assert series.include?("50")   # Current page as string
  end

  test "from and to calculations work correctly" do
    if SolidCacheDashboard.pagy_43_or_newer?
      pagy = Pagy::Offset.new(count: 25, page: 2, limit: 10)
      # Pagy 43 uses 'in' attribute
      assert_equal 10, pagy.in
    else
      pagy = Pagy.new(count: 25, page: 2, items: 10)
      # Older Pagy might have different attributes
    end
    
    assert_equal 11, pagy.from
    assert_equal 20, pagy.to
  end
end