require "test_helper"

class PagyCompatibilityTest < ActiveSupport::TestCase
  test "pagy_43_or_newer? detects version correctly" do
    if Gem::Version.new(Pagy::VERSION) >= Gem::Version.new('43.0.0')
      assert SolidCacheDashboard.pagy_43_or_newer?
    else
      refute SolidCacheDashboard.pagy_43_or_newer?
    end
  end

  test "pagy_series works with pagy objects" do
    # Create a mock pagy object based on version
    if SolidCacheDashboard.pagy_43_or_newer?
      # Pagy 43+ style
      pagy = Pagy::Offset.new(count: 100, page: 1, limit: 10)
      series = SolidCacheDashboard.pagy_series(pagy)
      
      assert series.is_a?(Array)
      assert series.include?(1)
      assert series.include?("1") # Current page as string
    else
      # Pagy 6-8.x style
      pagy = Pagy.new(count: 100, page: 1, items: 10)
      series = SolidCacheDashboard.pagy_series(pagy)
      
      assert series.is_a?(Array)
      assert series.include?(1)
      assert series.include?("1") # Current page as string
    end
  end
end
