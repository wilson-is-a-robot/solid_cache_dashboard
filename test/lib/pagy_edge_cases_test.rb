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

    if SolidCacheDashboard.pagy_43_or_newer?
      refute pagy.previous
    else
      refute pagy.prev
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

    if SolidCacheDashboard.pagy_43_or_newer?
      assert_equal 4, pagy.previous
    else
      assert_equal 4, pagy.prev
    end
  end

  test "from and to calculations work correctly" do
    if SolidCacheDashboard.pagy_43_or_newer?
      pagy = Pagy::Offset.new(count: 25, page: 2, limit: 10)
      assert_equal 10, pagy.in
    else
      pagy = Pagy.new(count: 25, page: 2, items: 10)
    end

    assert_equal 11, pagy.from
    assert_equal 20, pagy.to
  end
end
